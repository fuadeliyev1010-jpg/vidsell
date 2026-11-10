import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/models/auth_token.dart';
import 'package:vidsell/models/common/api_error.dart';
import 'package:vidsell/models/auth/auth_response.dart';

class ApiClient {
  static const _requestStartedAtKey = '_apiClientRequestStartedAt';
  static final _sensitiveKey = RegExp(
    r'(?:access[_-]?token|refresh[_-]?token|token|password|passwd|otp|one.?time.?code|code)',
    caseSensitive: false,
  );

  ApiClient({
    required AppConfig config,
    SessionStore? sessionStore,
    Dio? dio,
    Dio? refreshDio,
  }) : _sessionStore = sessionStore ?? const _NoopSessionStore(),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 30),
               headers: {'Accept': 'application/json'},
             ),
           ),
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 30),
               headers: {'Accept': 'application/json'},
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra[_requestStartedAtKey] = Stopwatch()..start();
          final session = await _sessionStore.read();
          if (session != null &&
              normalizeAuthToken(session.accessToken).isNotEmpty) {
            options.headers['Authorization'] = _authorizationHeader(session);
          }
          options.headers['X-App-Language'] = _languageCode;
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logRequest(response.requestOptions, statusCode: response.statusCode);
          handler.next(response);
        },
        onError: (error, handler) async {
          final apiError = ApiError.fromResponse(
            error.response?.data,
            status: error.response?.statusCode,
            fallbackCode: error.type.name,
          );
          _logRequest(
            error.requestOptions,
            statusCode: error.response?.statusCode,
            code: apiError.code,
            message: apiError.error ?? apiError.messageKey,
            dioExceptionType: error.type,
          );

          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final requestOptions = error.requestOptions;
          final isRefreshRequest =
              requestOptions.path.contains('/auth/refresh') ||
              requestOptions.extra['isRefresh'] == true;
          final isRetry = requestOptions.extra['isRetry'] == true;

          if (isRefreshRequest || isRetry) {
            return handler.next(error);
          }

          AuthSession? newSession;
          try {
            _refreshFuture ??= _performTokenRefresh();
            newSession = await _refreshFuture;
          } catch (_) {
            return handler.next(error);
          }
          if (newSession == null || newSession.accessToken.isEmpty) {
            return handler.next(error);
          }

          try {
            final retryOptions = Options(
              method: requestOptions.method,
              headers: Map<String, dynamic>.from(requestOptions.headers)
                ..['Authorization'] = _authorizationHeader(newSession)
                ..['X-App-Language'] = _languageCode,
              extra: Map<String, dynamic>.from(requestOptions.extra)
                ..['isRetry'] = true,
              responseType: requestOptions.responseType,
              contentType: requestOptions.contentType,
              validateStatus: requestOptions.validateStatus,
              receiveTimeout: requestOptions.receiveTimeout,
              sendTimeout: requestOptions.sendTimeout,
            );
            final response = await _dio.request<dynamic>(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: retryOptions,
            );
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );
  }

  static String _authorizationHeader(AuthSession session) =>
      'Bearer ${normalizeAuthToken(session.accessToken)}';

  final Dio _dio;
  final Dio _refreshDio;
  final SessionStore _sessionStore;
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Future<AuthSession?>? _refreshFuture;
  String _languageCode = 'tr';

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  void setLanguage(String languageCode) {
    if (languageCode == 'tr' || languageCode == 'en') {
      _languageCode = languageCode;
    }
  }

  void _notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  Future<AuthSession?> refreshTokenManually() => _performTokenRefresh();

  Future<AuthSession?> _performTokenRefresh() async {
    final stopwatch = Stopwatch()..start();
    _logRefresh('start');
    try {
      final currentSession = await _sessionStore.read();
      _logRefresh(
        'session state',
        detail: currentSession == null
            ? 'session=missing'
            : 'session=present accessLength=${currentSession.accessToken.length} '
                  'refreshLength=${currentSession.refreshToken.length}',
      );
      if (currentSession == null || currentSession.refreshToken.isEmpty) {
        _logRefresh('skipped', detail: 'session or refresh token missing');
        return null;
      }

      late final Response<dynamic> response;
      try {
        response = await _refreshDio.post<dynamic>(
          '/auth/refresh',
          data: {'refreshToken': currentSession.refreshToken},
          options: Options(
            extra: {'isRefresh': true},
            headers: {'X-App-Language': _languageCode},
          ),
        );
      } on DioException catch (error) {
        final apiError = ApiError.fromResponse(
          error.response?.data,
          status: error.response?.statusCode,
          fallbackCode: error.type.name,
        );
        _logRequest(
          error.requestOptions,
          statusCode: error.response?.statusCode,
          duration: stopwatch.elapsed,
          code: apiError.code,
          message: apiError.error ?? apiError.messageKey,
          dioExceptionType: error.type,
        );
        final statusCode = error.response?.statusCode;
        if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
          _logRefresh('rejected', statusCode: statusCode);
          await _expireSession();
        } else {
          _logRefresh('failed', statusCode: statusCode);
        }
        return null;
      }
      _logRequest(
        response.requestOptions,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        _logRefresh('invalid response', statusCode: response.statusCode);
        return null;
      }

      final authResponse = AuthResponse.fromJson(data);
      final newAccessToken = authResponse.accessToken;
      if (newAccessToken.isEmpty) {
        _logRefresh('missing access token', statusCode: response.statusCode);
        return null;
      }

      final updatedSession = currentSession.copyWith(
        accessToken: newAccessToken,
        refreshToken: authResponse.refreshToken.isEmpty
            ? currentSession.refreshToken
            : authResponse.refreshToken,
        tokenType: authResponse.tokenType.isEmpty
            ? currentSession.tokenType
            : authResponse.tokenType,
      );
      await _sessionStore.write(updatedSession);
      _logRefresh(
        'updated',
        statusCode: response.statusCode,
        detail:
            'session=present accessLength=${updatedSession.accessToken.length} '
            'refreshLength=${updatedSession.refreshToken.length}',
      );
      return updatedSession;
    } on DioException {
      rethrow;
    } catch (_) {
      _logRefresh('failed', detail: 'refresh processing error');
      return null;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _expireSession() async {
    try {
      await _sessionStore.clear();
    } finally {
      _logRefresh('session cleared');
      _notifySessionExpired();
    }
  }

  void _logRefresh(String result, {int? statusCode, String? detail}) {
    if (!kDebugMode) return;
    debugPrint(
      '[ApiClient] refresh $result'
      '${statusCode == null ? '' : ' status=$statusCode'}'
      '${detail == null ? '' : ' detail=$detail'}',
    );
  }

  void dispose() => _sessionExpiredController.close();

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _request(() => _dio.get(path, queryParameters: queryParameters));

  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> postMultipart(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
  }) => _request(
    () => _dio.post(path, data: data, onSendProgress: onSendProgress),
  );

  Future<dynamic> patch(String path, {Object? data}) =>
      _request(() => _dio.patch(path, data: data));

  Future<dynamic> put(String path, {Object? data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path) => _request(() => _dio.delete(path));

  Future<dynamic> _request(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      final apiError = ApiError.fromResponse(
        error.response?.data,
        status: error.response?.statusCode,
        fallbackCode: error.type.name,
      );
      throw ApiException(
        apiError.error ??
            apiError.messageKey ??
            'The request could not be completed.',
        statusCode: error.response?.statusCode,
        apiError: apiError,
        underlyingType: error.type,
      );
    }
  }

  void _logRequest(
    RequestOptions options, {
    int? statusCode,
    Duration? duration,
    String? code,
    String? message,
    DioExceptionType? dioExceptionType,
  }) {
    final requestTimer = options.extra.remove(_requestStartedAtKey);
    final elapsed =
        duration ??
        (requestTimer is Stopwatch ? requestTimer.elapsed : Duration.zero);
    if (!kDebugMode) return;

    final sensitiveValues = _sensitiveValues(options);
    final safeCode = code == null ? null : _redact(code, sensitiveValues);
    final safeMessage = message == null
        ? null
        : _redact(message, sensitiveValues).replaceAll('"', r'\"');
    final uri = options.uri.toString().replaceFirst(
      RegExp(r'//[^/@]+@'),
      '//[REDACTED]@',
    );
    final safeUri = uri.replaceAllMapped(
      RegExp(
        r'([?&][^=&#]*(?:access[_-]?token|refresh[_-]?token|token|password|otp|code)[^=&#]*=)[^&#]*',
        caseSensitive: false,
      ),
      (match) => '${match[1]}[REDACTED]',
    );
    final fields = <String>[
      '[ApiClient]',
      options.method,
      safeUri,
      'status=${statusCode ?? '-'}',
      'duration=${elapsed.inMilliseconds}ms',
      _maskedAuthorization(options),
      if (dioExceptionType != null) 'dioType=${dioExceptionType.name}',
      if (safeCode != null) 'code=$safeCode',
      if (safeMessage != null) 'message="$safeMessage"',
    ];
    debugPrint(fields.join(' '));
  }

  String _maskedAuthorization(RequestOptions options) {
    final header = options.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'authorization')
        .map((entry) => entry.value.toString())
        .firstOrNull;
    if (header == null || header.isEmpty) return 'Authorization: <missing>';

    final separator = header.indexOf(' ');
    if (separator <= 0) {
      return 'Authorization: [malformed] ****(len ${header.length})';
    }
    final scheme = header.substring(0, separator);
    final token = normalizeAuthToken(header.substring(separator + 1));
    return 'Authorization: $scheme ****(len ${token.length})';
  }

  List<String> _sensitiveValues(RequestOptions options) {
    final values = <String>[];
    final authorization = options.headers['Authorization'];
    if (authorization is String && authorization.isNotEmpty) {
      values.add(authorization);
      final separator = authorization.indexOf(' ');
      if (separator >= 0 && separator + 1 < authorization.length) {
        values.add(authorization.substring(separator + 1));
      }
    }

    void collect(Object? value) {
      if (value is Map) {
        for (final entry in value.entries) {
          if (_sensitiveKey.hasMatch(entry.key.toString())) {
            if (entry.value != null) values.add(entry.value.toString());
          } else {
            collect(entry.value);
          }
        }
      } else if (value is Iterable) {
        for (final item in value) {
          collect(item);
        }
      } else if (value is FormData) {
        for (final field in value.fields) {
          if (_sensitiveKey.hasMatch(field.key)) values.add(field.value);
        }
      }
    }

    collect(options.data);
    collect(options.queryParameters);
    collect(options.uri.queryParameters);
    return values.where((value) => value.isNotEmpty).toList(growable: false);
  }

  String _redact(String value, List<String> sensitiveValues) {
    var result = value.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    for (final secret in sensitiveValues) {
      result = result.replaceAll(secret, '[REDACTED]');
    }
    return result;
  }
}

class _NoopSessionStore implements SessionStore {
  const _NoopSessionStore();

  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> write(AuthSession session) async {}
}

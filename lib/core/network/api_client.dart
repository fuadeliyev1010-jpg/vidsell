import 'dart:async';

import 'package:dio/dio.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/models/common/api_error.dart';

class ApiClient {
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
          final session = await _sessionStore.read();
          if (session != null && session.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          options.headers['X-App-Language'] = _languageCode;
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final requestOptions = error.requestOptions;
          final isRefreshRequest =
              requestOptions.path.contains('/auth/refresh') ||
              requestOptions.extra['isRefresh'] == true;
          final isRetry = requestOptions.extra['isRetry'] == true;

          if (isRefreshRequest || isRetry) {
            await _sessionStore.clear();
            _notifySessionExpired();
            return handler.next(error);
          }

          try {
            _refreshFuture ??= _performTokenRefresh();
            final newSession = await _refreshFuture;
            if (newSession == null || newSession.accessToken.isEmpty) {
              return handler.next(error);
            }

            final retryOptions = Options(
              method: requestOptions.method,
              headers: Map<String, dynamic>.from(requestOptions.headers)
                ..['Authorization'] = 'Bearer ${newSession.accessToken}'
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
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );
  }

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
    try {
      final currentSession = await _sessionStore.read();
      if (currentSession == null || currentSession.refreshToken.isEmpty) {
        await _sessionStore.clear();
        _notifySessionExpired();
        return null;
      }

      final response = await _refreshDio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': currentSession.refreshToken},
        options: Options(
          extra: {'isRefresh': true},
          headers: {'X-App-Language': _languageCode},
        ),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        await _sessionStore.clear();
        _notifySessionExpired();
        return null;
      }

      final newAccessToken = (data['accessToken'] ?? data['token']) as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _sessionStore.clear();
        _notifySessionExpired();
        return null;
      }

      final updatedSession = currentSession.copyWith(
        accessToken: newAccessToken,
        refreshToken:
            (data['refreshToken'] as String?) ?? currentSession.refreshToken,
      );
      await _sessionStore.write(updatedSession);
      return updatedSession;
    } catch (_) {
      await _sessionStore.clear();
      _notifySessionExpired();
      return null;
    } finally {
      _refreshFuture = null;
    }
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
      );
    }
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

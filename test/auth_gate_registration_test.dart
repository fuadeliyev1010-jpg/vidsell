import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/api_auth_repository.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/features/auth/widgets/auth_gate.dart';
import 'package:vidsell/features/home/page/home_page.dart';
import 'package:vidsell/features/login/page/login_otp_page.dart';
import 'package:vidsell/features/login/widgets/otp_box.dart';
import 'package:vidsell/features/register/page/register_page.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';

void main() {
  testWidgets('API registration opens the registration form first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _OtpSentRepository();
    final authBloc = AuthBloc(repository: repository);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _RegistrationTestAuthGate(),
        ),
        _registrationTestPageRoute(),
      ],
    );
    addTearDown(() async {
      router.dispose();
      await authBloc.close();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => RepositoryProvider<AppConfig>.value(
          value: const AppConfig(useMockBackend: false),
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          ),
        ),
      ),
    );
    authBloc.add(const AuthStarted());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextButton, "Let's create your account"),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '+994501112233');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(repository.requests, isEmpty);
    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.byType(OtpPage), findsNothing);
    expect(authBloc.state.status, AuthStatus.unauthenticated);
    expect(authBloc.state.operation, AuthOperation.idle);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'six-digit API registration code reaches successful registration',
    () async {
      final fixture = _RegistrationApiFixture();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'))
        ..httpClientAdapter = fixture;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api/v1',
          useMockBackend: false,
        ),
        dio: dio,
      );
      final repository = ApiAuthRepository(
        client: client,
        sessionStore: InMemorySessionStore(),
      );
      final bloc = AuthBloc(repository: repository);
      addTearDown(() async {
        await bloc.close();
        client.dispose();
        dio.close(force: true);
      });

      bloc.add(const AuthStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.unauthenticated,
      );
      bloc.add(
        const RegistrationOtpRequested(
          identifier: '+994501112233',
          name: 'Test User',
          email: 'test@example.test',
          password: 'password-8',
        ),
      );
      await bloc.stream.firstWhere(
        (state) => state.operation == AuthOperation.otpSent,
      );
      bloc.add(const RegistrationOtpSubmitted('780423'));
      final registered = await bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.authenticated,
      );

      expect(registered.session, isNotNull);
      final registrationRequest = fixture.requests.singleWhere(
        (request) => request.path == '/auth/register',
      );
      expect(registrationRequest.data['verificationCode'], '780423');
      expect(registrationRequest.data['fullName'], 'Test User');
      expect(registrationRequest.data['countryCode'], '+994');
      expect(registrationRequest.data['phoneNumber'], '501112233');
      expect(registrationRequest.data['email'], 'test@example.test');
      expect(registrationRequest.data['password'], 'password-8');
      expect(registrationRequest.data['gender'], 'MALE');
      expect(registrationRequest.data['termsAccepted'], isTrue);
      expect(registrationRequest.data['role'], 'BUYER');
      expect(fixture.requests.map((request) => request.path), [
        '/auth/send-registration-otp',
        '/auth/register',
      ]);
    },
  );

  testWidgets('wrong API code stays on OTP and correct code registers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final registerGate = Completer<void>();
    final fixture = _RegistrationApiFixture(
      rejectFirstRegistration: true,
      registerGate: registerGate,
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'))
      ..httpClientAdapter = fixture;
    final client = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'https://api.example.test/api/v1',
        useMockBackend: false,
      ),
      dio: dio,
    );
    final repository = ApiAuthRepository(
      client: client,
      sessionStore: InMemorySessionStore(),
    );
    final authBloc = AuthBloc(repository: repository);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _RegistrationTestAuthGate(),
        ),
        _registrationTestPageRoute(),
      ],
    );
    addTearDown(() async {
      router.dispose();
      await authBloc.close();
      client.dispose();
      dio.close(force: true);
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => RepositoryProvider<AppConfig>.value(
          value: const AppConfig(useMockBackend: false),
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          ),
        ),
      ),
    );
    authBloc.add(const AuthStarted());
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TextButton, "Let's create your account"),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '+994501112233');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byType(RegisterPage), findsOneWidget);
    final registerFields = find.descendant(
      of: find.byType(RegisterPage),
      matching: find.byType(TextField),
    );
    await tester.enterText(registerFields.at(0), 'Test User');
    await tester.enterText(registerFields.at(1), 'test@example.test');
    await tester.enterText(registerFields.at(2), 'password-8');
    await tester.enterText(registerFields.at(3), 'password-8');
    final registerButton = find.descendant(
      of: find.byType(RegisterPage),
      matching: find.widgetWithText(OutlinedButton, 'Devam et'),
    );
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(OtpPage), findsOneWidget);

    for (var index = 0; index < 6; index++) {
      final otpBox = find.byType(OtpBox).at(index);
      await tester.enterText(
        find.descendant(of: otpBox, matching: find.byType(TextField)),
        '780423'[index],
      );
      await tester.pump();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(OtpPage),
        matching: find.widgetWithText(OutlinedButton, 'Devam et'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.byType(OtpPage), findsOneWidget);
    registerGate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(OtpPage), findsOneWidget);
    expect(find.text('The code expired (OTP_EXPIRED)'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(authBloc.state.pendingRegistration?.name, 'Test User');
    expect(authBloc.state.pendingRegistration?.email, 'test@example.test');
    expect(authBloc.state.pendingRegistration?.password, 'password-8');
    expect(
      fixture.requests
          .firstWhere((request) => request.path == '/auth/register')
          .data['verificationCode'],
      '780423',
    );

    await tester.tap(
      find.descendant(
        of: find.byType(OtpPage),
        matching: find.byIcon(Icons.arrow_back_ios_new),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.byType(OtpPage), findsNothing);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(
      tester.widget<TextField>(registerFields.at(0)).controller!.text,
      'Test User',
    );
    expect(
      tester.widget<TextField>(registerFields.at(1)).controller!.text,
      'test@example.test',
    );

    await tester.tap(registerButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(OtpPage), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(
      fixture.requests
          .where((request) => request.path == '/auth/send-registration-otp')
          .length,
      2,
    );

    for (var index = 0; index < 6; index++) {
      final otpBox = find.byType(OtpBox).at(index);
      await tester.enterText(
        find.descendant(of: otpBox, matching: find.byType(TextField)),
        '654321'[index],
      );
      await tester.pump();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(OtpPage),
        matching: find.widgetWithText(OutlinedButton, 'Devam et'),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    expect(authBloc.state.status, AuthStatus.authenticated);
    expect(find.byType(OtpPage), findsNothing);
    expect(find.byKey(const ValueKey('registered-home')), findsOneWidget);
    final registrationRequests = fixture.requests.where(
      (request) => request.path == '/auth/register',
    );
    expect(registrationRequests.length, 2);
    expect(registrationRequests.last.data['verificationCode'], '654321');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

GoRoute _registrationTestPageRoute() => GoRoute(
  path: '/page/:pageType',
  redirect: (context, state) {
    final page = state.extra;
    if (page is RoutedPage || page is Widget) return null;
    return '/';
  },
  pageBuilder: (context, state) {
    final extra = state.extra;
    final widget = extra is RoutedPage
        ? extra.child
        : extra is Widget
        ? extra
        : const SizedBox.shrink();
    return MaterialPage<void>(
      key: state.pageKey,
      child: widget is HomePage
          ? const SizedBox(key: ValueKey('registered-home'))
          : widget,
    );
  },
);

class _RegistrationTestAuthGate extends StatelessWidget {
  const _RegistrationTestAuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) => state.status == AuthStatus.authenticated
          ? const SizedBox(key: ValueKey('auth-gate-home'))
          : const AuthGate(),
    );
  }
}

class _RegistrationApiFixture implements HttpClientAdapter {
  _RegistrationApiFixture({
    this.rejectFirstRegistration = false,
    this.registerGate,
  });

  final bool rejectFirstRegistration;
  final Completer<void>? registerGate;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/auth/register' &&
        requests.where((request) => request.path == '/auth/register').length ==
            1) {
      await registerGate?.future;
    }
    if (options.path == '/auth/register' &&
        rejectFirstRegistration &&
        requests.where((request) => request.path == '/auth/register').length ==
            1) {
      return ResponseBody.fromString(
        jsonEncode({
          'status': 400,
          'error': 'The code expired',
          'code': 'OTP_EXPIRED',
        }),
        400,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final response = switch (options.path) {
      '/auth/send-registration-otp' => {'message': 'OTP sent'},
      '/auth/register' => _authResponse,
      _ => throw StateError('Unexpected auth route: ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  static final _authResponse = {
    'accessToken': base64Url.encode(utf8.encode('registration-access')),
    'refreshToken': base64Url.encode(utf8.encode('registration-refresh')),
    'tokenType': 'Bearer',
    'user': {
      'id': '00000000-0000-4000-8000-000000000001',
      'fullName': 'Test User',
      'countryCode': '+994',
      'phoneNumber': '501112233',
      'email': 'test@example.test',
      'avatarUrl': '',
      'gender': 'MALE',
      'role': 'BUYER',
      'createdAt': '2026-11-09T12:00:00Z',
    },
  };

  @override
  void close({bool force = false}) {}
}

class _OtpSentRepository extends MockAuthRepository {
  final requests = <SendOtpRequest>[];

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> sendOtp(SendOtpRequest request) async {
    requests.add(request);
  }
}

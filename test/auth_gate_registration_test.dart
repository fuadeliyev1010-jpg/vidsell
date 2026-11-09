import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/features/auth/widgets/auth_gate.dart';
import 'package:vidsell/features/login/page/login_otp_page.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';

void main() {
  testWidgets('registration OTP opens and stays on OTP page', (tester) async {
    final repository = _OtpSentRepository();
    final authBloc = AuthBloc(repository: repository);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const AuthGate()),
        routedPageRoute(),
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

    expect(repository.requests, hasLength(1));
    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(OtpPage), findsOneWidget);
    expect(authBloc.state.status, AuthStatus.unauthenticated);
    expect(authBloc.state.operation, AuthOperation.otpSent);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OtpPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
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

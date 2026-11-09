import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/features/home/page/home_page.dart';
import 'package:vidsell/features/login/page/login_page.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const HomePage();
          case AuthStatus.unknown:
          case AuthStatus.sendingOtp:
          case AuthStatus.verifyingOtp:
          case AuthStatus.registering:
          case AuthStatus.authenticating:
            return const _AuthLoadingPage();
          case AuthStatus.unauthenticated:
          case AuthStatus.otpSent:
          case AuthStatus.failure:
            return const LoginPage();
        }
      },
    );
  }
}

class _AuthLoadingPage extends StatelessWidget {
  const _AuthLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: CircularProgressIndicator(color: AppColor.activeColor),
      ),
    );
  }
}

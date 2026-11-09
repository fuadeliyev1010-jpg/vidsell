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
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            debugPrint('[AuthGate] ${state.status} -> HomePage');
            return const HomePage();
          case AuthStatus.unknown:
            debugPrint('[AuthGate] ${state.status} -> loading page');
            return const _AuthLoadingPage();
          case AuthStatus.unauthenticated:
            debugPrint('[AuthGate] ${state.status} -> LoginPage');
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

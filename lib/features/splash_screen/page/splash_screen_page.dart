import 'package:flutter/material.dart';
import 'package:vidsell/core/constants/app_color.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(child: Image.asset('assets/images/Vidsell logo 2.png')),
    );
  }
}

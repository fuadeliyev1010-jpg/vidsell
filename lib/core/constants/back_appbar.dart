import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';

class BackAppbar {
  final VoidCallback? onPressed;
  BackAppbar({required this.onPressed});
  AppBar get appbar => AppBar(
    toolbarHeight: 48.h,
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new),
      color: AppColor.tertiaryTextColor,
    ),
  );
}

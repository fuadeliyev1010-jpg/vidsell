import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle get primaryText => TextStyle(
    color: Colors.white,
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get mutedText => TextStyle(
    color: AppColor.mutedColor,
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get activeText => TextStyle(
    color: AppColor.activeColor,
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get secondaryText => TextStyle(
    color: AppColor.secondaryTextColor,
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get specialText => TextStyle(
    color: AppColor.tertiaryTextColor,
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );
}

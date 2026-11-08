import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? height;
  final IconData? icon;
  final bool iconTrailing;
  final BorderSide? side;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.height,
    this.icon,
    this.iconTrailing = false,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: AppTextStyle.primaryText.copyWith(
        color: textColor ?? Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );

    final child = icon == null
        ? label
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: iconTrailing
                ? [
                    label,
                    4.width,
                    Icon(icon, color: textColor ?? Colors.white, size: 15.sp),
                  ]
                : [
                    Icon(icon, color: textColor ?? Colors.white, size: 16.sp),
                    4.width,
                    label,
                  ],
          );

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: color ?? AppColor.activeColor,
        minimumSize: Size.fromHeight(height ?? 56.h),
        side: side,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      child: child,
    );
  }
}

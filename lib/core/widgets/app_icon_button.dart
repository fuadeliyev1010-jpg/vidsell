import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? iconPath;
  final IconData? icon;
  final double? radius;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const AppIconButton({
    super.key,
    required this.onPressed,
    this.iconPath,
    this.icon,
    this.radius,
    this.backgroundColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 68.h,
      width: width ?? 68.w,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor ?? AppColor.bgSurfaceColor,
          // Same fix as AppButton — without this, OutlinedButton adds a
          // faint default border around the Google/Apple squares that
          // the design doesn't have.
          side: BorderSide.none,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 14.r),
          ),
        ),
        child: iconPath != null
            ? SvgPicture.asset(iconPath!, height: 24.h, width: 24.w)
            : Icon(icon, size: 24.sp),
      ),
    );
  }
}

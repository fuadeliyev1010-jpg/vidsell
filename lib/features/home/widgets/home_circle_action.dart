import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeCircleAction extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  final Widget? customIcon;
  final Color? iconColor;

  const HomeCircleAction({
    super.key,
    required this.iconPath,
    required this.onTap,
    this.customIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.all(4.sp),
        child:
            customIcon ??
            SvgPicture.asset(
              iconPath,
              height: 32.h,
              width: 32.w,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                  : null,
            ),
      ),
    );
  }
}

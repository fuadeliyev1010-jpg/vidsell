import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

class HomeBadge extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final String? imagePath;

  const HomeBadge({
    super.key,
    this.label,
    this.icon,
    required this.color,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14.sp, color: color), 4.width],
          if (path != null) ...[
            SvgPicture.asset(path, height: 14.h, width: 14.w),
            4.width,
          ],
          Text(
            label ?? "",
            style: AppTextStyle.mutedText.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

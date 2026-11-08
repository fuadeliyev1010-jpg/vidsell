import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// Small pill badge shown next to the verified phone number.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      width: 111.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            context.l10n.listingVerified,
            style: AppTextStyle.mutedText.copyWith(color: AppColor.success),
          ),
        ],
      ),
    );
  }
}

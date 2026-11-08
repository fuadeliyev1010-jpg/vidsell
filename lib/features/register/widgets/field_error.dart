import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_text_style.dart';

/// Red inline error shown under a form field, or nothing when error is null.
class FieldError extends StatelessWidget {
  final String? text;

  const FieldError({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 2.h, left: 8.w, right: 8.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text!,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.red,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

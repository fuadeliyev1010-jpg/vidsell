import 'package:flutter/material.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransparentTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? isExpanded;
  final bool isSelected;
  const TransparentTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isExpanded,
    this.isSelected = false,
  });

  @override
  State<TransparentTextButton> createState() => _TransparentTextButtonState();
}

class _TransparentTextButtonState extends State<TransparentTextButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: widget.onPressed,
        child: Container(
          height: 41.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withValues(
              alpha: widget.isSelected ? 0.75 : 0.4,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              4.width,
              if (widget.isExpanded == true)
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';

BoxDecoration get listingFieldDecoration => BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: AppColor.bgElavated),
);

/// Input decoration with no fill and no borders, so the surrounding
/// container (listingFieldDecoration) is the only visible box.
/// This overrides whatever the global InputDecorationTheme sets.
InputDecoration listingInputDecoration({String? label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
    floatingLabelStyle: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
    hintStyle: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: false,
    fillColor: Colors.transparent,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
  );
}

class ListingSectionHeader extends StatelessWidget {
  const ListingSectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        label,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ListingRadioRow extends StatelessWidget {
  const ListingRadioRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Container(
          decoration: listingFieldDecoration,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColor.activeColor
                          : AppColor.tertiaryTextColor,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.activeColor,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListingTextField extends StatelessWidget {
  const ListingTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: listingFieldDecoration,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: listingInputDecoration(label: label),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

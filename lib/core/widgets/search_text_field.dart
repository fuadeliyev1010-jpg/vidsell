import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchTextField({super.key, required this.controller, this.onChanged});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 37.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppColor.activeColor
              : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.searchProduct,
          hintStyle: AppTextStyle.primaryText.copyWith(
            color: AppColor.tertiaryTextColor,
            fontSize: 14.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14.w, right: 9.w),
            child: Center(
              widthFactor: 1,
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 20.sp,
                height: 20.sp,
                colorFilter: const ColorFilter.mode(
                  AppColor.secondaryTextColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 43.w, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        ),
      ),
    );
  }
}

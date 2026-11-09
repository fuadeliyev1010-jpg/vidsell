import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';

/// Single OTP digit entry box with dynamic border highlighting on focus.
class OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      height: 60.h,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, child) {
          final isFocused = focusNode.hasFocus;
          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isFocused ? AppColor.activeColor : AppColor.bgElavated,
                width: isFocused ? 1.5 : 1,
              ),
            ),
            child: child,
          );
        },
        // Focus wrapper catches key events from the TextField, so no extra
        // FocusNode is created on every build (the old code leaked one).
        child: Focus(
          skipTraversal: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                controller.text.isEmpty) {
              onBackspace();
            }
            return KeyEventResult.ignored;
          },
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: AppColor.activeColor,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
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
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

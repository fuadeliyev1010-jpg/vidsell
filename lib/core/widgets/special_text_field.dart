import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';

/// A text field with a floating label.
///
/// This widget only positions its own children (TextField + label) with
/// [Positioned] inside a [Stack] — it holds no opinion about its own size
/// or where it sits on the page. Whoever places it (e.g. inside a parent
/// [Stack] via [Positioned]/[AnimatedPositioned], or inside a fixed-height
/// [SizedBox]) is responsible for giving it bounds.
class SpecialTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;

  /// When true, the field's border (enabled + focused) turns red to
  /// signal a validation error. The border itself never doubles up —
  /// it's the same [OutlineInputBorder], just recolored.
  final bool hasError;

  /// Optional leading icon (e.g. person/email/lock) shown at the start
  /// of the field, matching the account-creation form design.
  final IconData? prefixIcon;
  final String? imagePath;

  /// When true, shows a trailing eye icon that toggles obscuring the
  /// text — used for password / confirm-password fields. The initial
  /// obscured state still comes from [obscureText].
  final bool showObscureToggle;

  /// Duration/curve for the floating-label animation. Reacts immediately
  /// to focus or text changes — no delay of any kind.
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;

  /// When false, skips the animated floating-label layout entirely and
  /// renders as a plain, vertically-centered TextField with a static
  /// hint (like a chat/search input). The floating-label Stack assumes
  /// a tall field (~68.h+) to have room to animate into; forcing it
  /// into a short field like a 44.h chat input causes "Cannot hit test
  /// a render box with no size" and misaligned text — there just isn't
  /// vertical room for that layout to resolve.
  final bool floatingLabel;

  const SpecialTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.focusNode,
    this.hasError = false,
    this.prefixIcon,
    this.imagePath,
    this.showObscureToggle = false,
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOut,
    this.backgroundColor,
    this.floatingLabel = true,
  });

  @override
  State<SpecialTextField> createState() => _SpecialTextFieldState();
}

class _SpecialTextFieldState extends State<SpecialTextField>
    with SingleTickerProviderStateMixin {
  FocusNode? _internalFocusNode;

  late final AnimationController _labelController;
  late final Animation<double> _labelAnimation;

  static const Color _normalBorderColor = Color(0xFF3A3A3A);
  static const Color _focusedBorderColor = Color(0xFF2FC2E8);
  static const Color _errorBorderColor = Colors.red;

  // Only used when widget.showObscureToggle is true; starts from the
  // widget's initial obscureText value and flips independently after.
  late bool _obscureText = widget.obscureText;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _isFocused => _effectiveFocusNode.hasFocus;

  bool get _showTopLabel => _isFocused || widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _labelController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _showTopLabel ? 1 : 0,
    );
    _labelAnimation = CurvedAnimation(
      parent: _labelController,
      curve: widget.animationCurve,
    );

    _effectiveFocusNode.addListener(_handleChange);
    widget.controller.addListener(_handleChange);
  }

  void _handleChange() {
    if (!mounted) return;
    if (_showTopLabel) {
      _labelController.forward();
    } else {
      _labelController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant SpecialTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleChange);
      _internalFocusNode?.removeListener(_handleChange);

      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }

      _effectiveFocusNode.addListener(_handleChange);
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }

    if (widget.animationDuration != oldWidget.animationDuration) {
      _labelController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleChange);
    widget.controller.removeListener(_handleChange);
    _internalFocusNode?.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabledColor = widget.hasError
        ? _errorBorderColor
        : _normalBorderColor;
    final focusedColor = widget.hasError
        ? _errorBorderColor
        : _focusedBorderColor;

    // Compact, non-floating mode: a plain, vertically-centered TextField
    // with a static hint — used for short fields (e.g. a 44.h chat/search
    // input) where the animated floating-label layout below has no room
    // to resolve.
    if (!widget.floatingLabel) {
      return TextField(
        controller: widget.controller,
        focusNode: _effectiveFocusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.showObscureToggle
            ? _obscureText
            : widget.obscureText,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 13.sp,
        ),
        cursorColor: AppColor.activeColor,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: widget.backgroundColor ?? Colors.transparent,
          hintText: widget.hintText,
          hintStyle: AppTextStyle.specialText.copyWith(
            fontSize: 13.sp,
            color: AppColor.secondaryTextColor,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: AppColor.secondaryTextColor,
                  size: 20.sp,
                )
              : widget.imagePath != null
              ? UnconstrainedBox(
                  child: SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: SvgPicture.asset(
                      widget.imagePath!,
                      height: 20.h,
                      width: 20.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : null,
          suffixIcon: widget.showObscureToggle
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColor.secondaryTextColor,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: enabledColor, width: 1.5.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: focusedColor, width: 1.5.w),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _labelAnimation,
      builder: (context, child) {
        final labelT = _labelAnimation.value;
        final contentPaddingTop = lerpDouble(18, 24, labelT)!;

        final hasPrefix = widget.prefixIcon != null || widget.imagePath != null;

        // FIX: in both screenshots, the placeholder / floating label sit
        // at the SAME horizontal position — it only moves up and shrinks,
        // it never slides sideways. The old code lerped from 50.w to
        // 16.w for the no-prefix case, which pushed the unfocused/empty
        // placeholder way further right than the design shows. Now it's
        // a constant left inset in both states (still offset when there
        // IS a prefix icon, so the label clears the icon).
        final labelLeft = hasPrefix ? 50.w : 16.w;
        final labelTop = lerpDouble(13.h, 2.h, labelT)!;
        final labelFontSize = lerpDouble(16.sp, 12.sp, labelT)!;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: TextField(
                controller: widget.controller,
                focusNode: _effectiveFocusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.showObscureToggle
                    ? _obscureText
                    : widget.obscureText,
                style: AppTextStyle.primaryText.copyWith(color: Colors.white),
                cursorColor: AppColor.activeColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.backgroundColor ?? Colors.transparent,
                  hintText: "",
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: AppColor.secondaryTextColor,
                          size: 20.sp,
                        )
                      : widget.imagePath != null
                      ? UnconstrainedBox(
                          child: SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: SvgPicture.asset(
                              widget.imagePath!,
                              height: 20.h,
                              width: 20.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : null,
                  suffixIcon: widget.showObscureToggle
                      ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColor.secondaryTextColor,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.fromLTRB(
                    16.w,
                    contentPaddingTop,
                    16.w,
                    18.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: enabledColor, width: 1.5.w),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: focusedColor, width: 1.5.w),
                  ),
                ),
              ),
            ),
            Positioned(
              left: labelLeft,
              top: labelTop,
              child: IgnorePointer(
                child: DefaultTextStyle(
                  style: AppTextStyle.specialText.copyWith(
                    fontSize: labelFontSize,
                  ),
                  child: Text(widget.hintText),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

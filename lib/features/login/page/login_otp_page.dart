import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/constants/back_appbar.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/format_phone_number.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/login/widgets/otp_box.dart';
import 'package:vidsell/features/register/page/register_page.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/home/page/home_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _otpLength = 4;
  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOut;

  // Gap between the subtitle and the OTP boxes — shrinks on focus.
  static const double _fieldGapNormal = 40;
  static const double _fieldGapFocused = 18;

  // Gap above the title — tightens on focus.
  static const double _topGapNormal = 24;
  static const double _topGapFocused = 8;

  static const int _resendSeconds = 176; // 02:56

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isFocused = false;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(_handleFocusChange);
    }
    _startResendTimer();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    final anyFocused = _focusNodes.any((n) => n.hasFocus);
    if (anyFocused != _isFocused) {
      setState(() => _isFocused = anyFocused);
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isOtpComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index + 1 < _otpLength) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {}); // Rebuild to update button state
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
    setState(() {}); // Rebuild to update button state
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final node in _focusNodes) {
      node.removeListener(_handleFocusChange);
      node.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.goAndClear(const HomePage());
        } else if (state.operation == AuthOperation.otpSent &&
            state.verificationCode != null) {
          context.goTo(
            RegisterPage(
              phoneNumber: widget.phoneNumber,
              verificationCode: state.verificationCode!,
            ),
          );
        } else if (state.operation == AuthOperation.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.localizedAuthError(state.errorCode)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        resizeToAvoidBottomInset: true,
        appBar: BackAppbar(onPressed: context.goBack).appbar,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: bottomInset > 0 ? bottomInset + 16.h : 24.h,
            ),
            physics: const ClampingScrollPhysics(),
            child: AnimatedSize(
              duration: _duration,
              curve: _curve,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: _duration,
                    curve: _curve,
                    height: _isFocused ? _topGapFocused : _topGapNormal,
                  ),

                  Center(
                    child: Text(
                      context.l10n.verifyIdentity,
                      style: AppTextStyle.primaryText.copyWith(fontSize: 24.sp),
                    ),
                  ),

                  8.height,

                  Center(
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        style: AppTextStyle.specialText,
                        children: [
                          TextSpan(text: context.l10n.otpCodePrefix),
                          TextSpan(text: formatPhoneNumber(widget.phoneNumber)),
                          TextSpan(text: context.l10n.otpCodeSuffix),
                        ],
                      ),
                    ),
                  ),

                  AnimatedContainer(
                    duration: _duration,
                    curve: _curve,
                    height: _isFocused ? _fieldGapFocused : _fieldGapNormal,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (index) {
                      return OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onDigitChanged(index, value),
                        onBackspace: () => _onBackspace(index),
                      );
                    }),
                  ),

                  56.height,

                  SizedBox(
                    width: double.infinity,
                    child: Opacity(
                      opacity: _isOtpComplete ? 1.0 : 0.5,
                      child: AppButton(
                        height: 48.h,
                        text: 'Devam et',
                        onPressed: _isOtpComplete
                            ? () {
                                final code = _controllers
                                    .map((controller) => controller.text)
                                    .join();
                                context.read<AuthBloc>().add(
                                  OtpSubmitted(
                                    identifier: widget.phoneNumber,
                                    code: code,
                                  ),
                                );
                              }
                            : () {}, // Empty function when disabled
                      ),
                    ),
                  ),

                  14.height,

                  Center(
                    child: _secondsLeft > 0
                        ? Text.rich(
                            TextSpan(
                              style: AppTextStyle.primaryText.copyWith(
                                fontSize: 13.sp,
                                color: AppColor.tertiaryTextColor,
                              ),
                              children: [
                                TextSpan(text: context.l10n.resendCode),
                                TextSpan(
                                  text: _formattedTime,
                                  style: const TextStyle(
                                    color: AppColor.activeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                        : TextButton(
                            onPressed: _startResendTimer,
                            child: Text(
                              context.l10n.resendCode,
                              style: AppTextStyle.primaryText.copyWith(
                                fontSize: 13.sp,
                                color: AppColor.activeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

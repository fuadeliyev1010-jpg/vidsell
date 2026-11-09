import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/constants/back_appbar.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/format_phone_number.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/login/widgets/otp_box.dart';
import 'package:vidsell/features/auth/constants/auth_constants.dart';
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
  static const _otpLength = authOtpLength;
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
  bool _isSubmitting = false;
  bool _hasNavigated = false;
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

  void _resendCode() {
    final operation = context.read<AuthBloc>().state.operation;
    if (operation == AuthOperation.sendingOtp ||
        (_secondsLeft > 0 && operation != AuthOperation.failure)) {
      return;
    }
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
    context.read<AuthBloc>().add(OtpRequested(widget.phoneNumber));
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

  void _submitCode() {
    if (!_isOtpComplete || _isSubmitting || _hasNavigated) return;

    final code = _controllers.map((controller) => controller.text).join();
    final authBloc = context.read<AuthBloc>();
    final isMockBackend = context.read<AppConfig>().useMockBackend;
    debugPrint(
      '[OtpPage] Submit pressed; mode=${isMockBackend ? 'mock' : 'api'}, '
      'codeLength=${code.length}',
    );
    setState(() => _isSubmitting = true);
    if (isMockBackend) {
      authBloc.add(OtpSubmitted(identifier: widget.phoneNumber, code: code));
    } else {
      authBloc.add(RegistrationOtpSubmitted(code));
    }
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
    final authState = context.watch<AuthBloc>().state;
    final isMockBackend = context.read<AppConfig>().useMockBackend;
    final isSubmitting =
        _isSubmitting || authState.operation == AuthOperation.registering;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && !_hasNavigated) {
          _hasNavigated = true;
          context.goAndClear(const HomePage());
        } else if (isMockBackend &&
            state.operation == AuthOperation.otpSent &&
            state.verificationCode != null) {
          _hasNavigated = true;
          context
              .goTo(
                RegisterPage(
                  phoneNumber: widget.phoneNumber,
                  verificationCode: state.verificationCode!,
                ),
              )
              .whenComplete(() => _hasNavigated = false);
        } else if (state.operation == AuthOperation.otpSent) {
          _startResendTimer();
        } else if (state.operation == AuthOperation.failure && mounted) {
          setState(() => _isSubmitting = false);
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

                  if (authState.operation == AuthOperation.failure &&
                      authState.displayError != null) ...[
                    16.height,
                    Text(
                      authState.errorMessage == null
                          ? context.l10n.localizedAuthError(authState.errorCode)
                          : authState.displayError!,
                      key: const ValueKey('registration-otp-error'),
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.redAccent,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],

                  56.height,

                  SizedBox(
                    width: double.infinity,
                    child: Opacity(
                      opacity: _isOtpComplete ? 1.0 : 0.5,
                      child: AppButton(
                        height: 48.h,
                        text: 'Devam et',
                        isLoading: isSubmitting,
                        onPressed: _isOtpComplete && !isSubmitting
                            ? _submitCode
                            : () {},
                      ),
                    ),
                  ),

                  14.height,

                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyle.primaryText.copyWith(
                          fontSize: 13.sp,
                          color: AppColor.tertiaryTextColor,
                        ),
                        children: [
                          TextSpan(text: context.l10n.resendCode),
                          TextSpan(
                            text: ' $_formattedTime',
                            style: const TextStyle(
                              color: AppColor.activeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed:
                          authState.operation == AuthOperation.sendingOtp ||
                              (_secondsLeft > 0 &&
                                  authState.operation != AuthOperation.failure)
                          ? null
                          : _resendCode,
                      child: Text(context.l10n.resendCode),
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

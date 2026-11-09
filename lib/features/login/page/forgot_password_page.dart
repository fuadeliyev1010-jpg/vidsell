import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/features/auth/constants/auth_constants.dart';
import 'package:vidsell/models/auth/reset_password_request.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _completed = false;
  bool _isSubmitting = false;
  String? _errorText;

  String _formatError(Object error) {
    if (error is! ApiException) return error.toString();
    final code = error.code;
    return code == null ? error.message : '${error.message} ($code)';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  (String, String)? get _phoneParts {
    var digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('994')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length < 7 || digits.length > 15) return null;
    return ('+994', digits);
  }

  Future<void> _sendCode() async {
    final phone = _phoneParts;
    if (phone == null) {
      setState(() => _errorText = context.l10n.loginIdentifierInvalid);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      final repository = context.read<AuthRepository>();
      await repository.requestPasswordReset(
        SendOtpRequest(countryCode: phone.$1, phoneNumber: phone.$2),
      );
      if (mounted) setState(() => _codeSent = true);
    } catch (error) {
      if (mounted) setState(() => _errorText = _formatError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    final phone = _phoneParts;
    final password = _passwordController.text;
    if (phone == null || _codeController.text.trim().length != authOtpLength) {
      setState(() => _errorText = context.l10n.loginIdentifierInvalid);
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = context.l10n.passwordMinLength(8));
      return;
    }
    if (password != _confirmPasswordController.text) {
      setState(() => _errorText = context.l10n.passwordsMismatch);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      final repository = context.read<AuthRepository>();
      final reset = await repository.verifyOtp(
        VerifyOtpRequest(
          countryCode: phone.$1,
          phoneNumber: phone.$2,
          code: _codeController.text.trim(),
        ),
      );
      await repository.resetPassword(
        ResetPasswordRequest(
          resetToken: reset.resetToken,
          newPassword: password,
        ),
      );
      if (mounted) setState(() => _completed = true);
    } catch (error) {
      if (mounted) setState(() => _errorText = _formatError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _submit() {
    if (_isSubmitting) return;
    unawaited(_codeSent ? _resetPassword() : _sendCode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        leading: IconButton(
          onPressed: context.goBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(context.l10n.faqForgotPassword),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            if (_completed) ...[
              48.height,
              Icon(Icons.check_circle, color: AppColor.success, size: 54.sp),
              20.height,
              Text(
                context.l10n.passwordResetComplete,
                textAlign: TextAlign.center,
                style: AppTextStyle.primaryText.copyWith(fontSize: 16.sp),
              ),
              24.height,
              AppButton(
                text: context.l10n.continueAction,
                onPressed: context.goBack,
              ),
            ] else ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyle.primaryText,
                decoration: InputDecoration(
                  labelText: context.l10n.phone,
                  labelStyle: const TextStyle(
                    color: AppColor.tertiaryTextColor,
                  ),
                ),
              ),
              if (_codeSent) ...[
                16.height,
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: authOtpLength,
                  style: AppTextStyle.primaryText,
                  decoration: InputDecoration(
                    labelText: context.l10n.verifyIdentity,
                    labelStyle: const TextStyle(
                      color: AppColor.tertiaryTextColor,
                    ),
                  ),
                ),
                12.height,
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTextStyle.primaryText,
                  decoration: InputDecoration(
                    labelText: context.l10n.password,
                    labelStyle: const TextStyle(
                      color: AppColor.tertiaryTextColor,
                    ),
                  ),
                ),
                12.height,
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: AppTextStyle.primaryText,
                  decoration: InputDecoration(
                    labelText: context.l10n.repeatPassword,
                    labelStyle: const TextStyle(
                      color: AppColor.tertiaryTextColor,
                    ),
                  ),
                ),
              ],
              if (_errorText != null) ...[
                12.height,
                Text(
                  _errorText!,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
                ),
              ],
              24.height,
              AppButton(
                text: _codeSent
                    ? context.l10n.continueAction
                    : context.l10n.smsCodeSend,
                onPressed: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

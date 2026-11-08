import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/constants/back_appbar.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/special_text_field.dart';
import 'package:vidsell/features/login/page/login_otp_page.dart';
import 'package:vidsell/features/login/widgets/login_terms_text.dart';
import 'package:vidsell/features/login/widgets/social_login_section.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOut;

  // Logo shrinks when focused to free up room for the keyboard.
  // NOTE: these are base (design) values — always apply `.h` when using them.
  static const double _logoHeightNormal = 124;
  static const double _logoHeightFocused = 70;

  // Gap between the title text and the field.
  static const double _fieldGapNormal = 64;
  static const double _fieldGapFocused = 24;

  bool _isFocused = false;

  // Validation state for the phone/email field.
  String? _errorText;
  bool _hasOpenedOtpPage = false;

  // Azerbaijani phone validation regex (accepts +994/994/0 prefixes, or none).
  static final RegExp _phoneRegex = RegExp(
    r'^(?:\+994|994|0)?(10|50|51|55|60|70|77|99)\d{7}$',
  );

  // Standard email validation regex.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  bool get _hasError => _errorText != null;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
      // Refocusing the field resets it to a clean, error-free state.
      if (_isFocused && _errorText != null) {
        _errorText = null;
      }
    });
  }

  // Clear the error as soon as the user edits the field again.
  void _handleTextChange() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  /// Strips spaces (including non-breaking/unicode spaces), hyphens,
  /// and parentheses so pasted or autocorrected numbers still validate.
  String _cleanPhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-\(\)\u00A0\u200B]'), '');
  }

  /// Returns true if the input is a valid AZ phone number or email.
  bool _isValidInput(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return false;

    if (_emailRegex.hasMatch(value)) return true;

    final phone = _cleanPhone(value);
    if (_phoneRegex.hasMatch(phone)) return true;

    return false;
  }

  /// Normalizes any accepted phone format to +994XXXXXXXXX.
  String _normalizePhoneNumber(String rawValue) {
    final value = _cleanPhone(rawValue.trim());
    if (value.startsWith('+994')) return value;
    if (value.startsWith('994')) return '+$value';
    if (value.startsWith('0')) return '+994${value.substring(1)}';
    return '+994$value'; // bare number, e.g. 505676754
  }

  void _handleContinuePressed() {
    final value = _controller.text;

    if (!_isValidInput(value)) {
      setState(() {
        _errorText = value.trim().isEmpty
            ? context.l10n.loginIdentifierRequired
            : context.l10n.loginIdentifierInvalid;
      });
      return;
    }

    setState(() => _errorText = null);
    _hasOpenedOtpPage = false;

    final trimmed = value.trim();
    final isEmail = _emailRegex.hasMatch(trimmed);

    final identifier = isEmail ? trimmed : _normalizePhoneNumber(trimmed);
    context.read<AuthBloc>().add(OtpRequested(identifier));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Real keyboard height for this frame.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent &&
            state.identifier != null &&
            !_hasOpenedOtpPage) {
          _hasOpenedOtpPage = true;
          context.goTo(OtpPage(phoneNumber: state.identifier!));
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.localizedAuthError(state.errorMessage),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        resizeToAvoidBottomInset: true,
        appBar: BackAppbar(onPressed: () {}).appbar,
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  bottom: bottomInset > 0 ? bottomInset + 16.h : 0,
                ),
                physics: const ClampingScrollPhysics(),
                child: IntrinsicHeight(
                  child: AnimatedSize(
                    duration: _duration,
                    curve: _curve,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: _duration,
                          curve: _curve,
                          height: _isFocused
                              ? _logoHeightFocused.h
                              : _logoHeightNormal.h,
                          child: Image.asset(
                            'assets/images/Vidsell_logoo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        _isFocused ? 24.height : 48.height,
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isFocused ? 60.w : 20.w,
                          ),
                          child: Text(
                            context.l10n.loginOrRegister,
                            style: AppTextStyle.primaryText.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: _isFocused ? 16.sp : 24.sp,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        AnimatedContainer(
                          duration: _duration,
                          curve: _curve,
                          height: _isFocused
                              ? _fieldGapFocused.h
                              : _fieldGapNormal.h,
                        ),

                        SizedBox(
                          height: 64.h,
                          child: SpecialTextField(
                            hintText: context.l10n.phoneOrEmail,
                            controller: _controller,
                            focusNode: _focusNode,
                            hasError: _hasError,
                          ),
                        ),

                        if (_hasError)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorText!,
                              style: AppTextStyle.primaryText.copyWith(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),

                        _isFocused ? 14.height : 24.height,

                        AppButton(
                          height: 48.h,
                          text: 'Devam et',
                          onPressed: _handleContinuePressed,
                        ),
                        14.height,
                        const LoginTermsText(),

                        28.height,

                        const SocialLoginSection(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/constants/back_appbar.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/special_text_field.dart';
import 'package:vidsell/features/login/page/login_otp_page.dart';
import 'package:vidsell/features/login/page/forgot_password_page.dart';
import 'package:vidsell/features/register/page/register_page.dart';
import 'package:vidsell/features/home/page/home_page.dart';
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
  final TextEditingController _passwordController = TextEditingController();
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
  String? _passwordErrorText;
  bool _hasOpenedOtpPage = false;
  bool _isRegistrationMode = false;

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
    _passwordController.addListener(_handlePasswordChange);
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

  void _handlePasswordChange() {
    if (_passwordErrorText != null) {
      setState(() => _passwordErrorText = null);
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
    final apiMode = !context.read<AppConfig>().useMockBackend;
    final trimmed = value.trim();
    final isEmail = _emailRegex.hasMatch(trimmed);

    if (!_isValidInput(value) || (apiMode && isEmail)) {
      setState(() {
        _errorText = value.trim().isEmpty
            ? context.l10n.loginIdentifierRequired
            : context.l10n.loginIdentifierInvalid;
      });
      return;
    }

    setState(() => _errorText = null);
    _hasOpenedOtpPage = false;

    final identifier = isEmail ? trimmed : _normalizePhoneNumber(trimmed);
    if (apiMode && !_isRegistrationMode) {
      if (_passwordController.text.isEmpty) {
        setState(() => _passwordErrorText = context.l10n.passwordMinLength(1));
        return;
      }
      context.read<AuthBloc>().add(
        PasswordLoginSubmitted(
          identifier: identifier,
          password: _passwordController.text,
        ),
      );
    } else if (apiMode) {
      context.goTo(RegisterPage(phoneNumber: identifier));
    } else {
      context.read<AuthBloc>().add(OtpRequested(identifier));
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _passwordController.removeListener(_handlePasswordChange);
    _controller.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Real keyboard height for this frame.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final apiMode = !context.read<AppConfig>().useMockBackend;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state.status == AuthStatus.authenticated && !_hasOpenedOtpPage) {
          context.goAndClear(const HomePage());
        } else if (state.operation == AuthOperation.otpSent &&
            state.identifier != null &&
            !_hasOpenedOtpPage) {
          _hasOpenedOtpPage = true;
          context.goTo(OtpPage(phoneNumber: state.identifier!));
        } else if (state.operation == AuthOperation.failure &&
            state.errorMessage != null &&
            !_hasOpenedOtpPage) {
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
                            hintText: apiMode
                                ? context.l10n.phone
                                : context.l10n.phoneOrEmail,
                            controller: _controller,
                            focusNode: _focusNode,
                            hasError: _hasError,
                          ),
                        ),

                        if (apiMode && !_isRegistrationMode) ...[
                          12.height,
                          SizedBox(
                            height: 64.h,
                            child: SpecialTextField(
                              hintText: context.l10n.password,
                              controller: _passwordController,
                              obscureText: true,
                              showObscureToggle: true,
                              hasError: _passwordErrorText != null,
                            ),
                          ),
                          if (_passwordErrorText != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _passwordErrorText!,
                                style: AppTextStyle.primaryText.copyWith(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],

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
                          text: context.l10n.continueAction,
                          onPressed: _handleContinuePressed,
                        ),
                        if (apiMode) ...[
                          8.height,
                          TextButton(
                            onPressed: () => setState(() {
                              _isRegistrationMode = !_isRegistrationMode;
                              _errorText = null;
                              _passwordErrorText = null;
                            }),
                            child: Text(
                              _isRegistrationMode
                                  ? context.l10n.loginOrRegister
                                  : context.l10n.registerIntro,
                            ),
                          ),
                          if (!_isRegistrationMode)
                            TextButton(
                              onPressed: () =>
                                  context.goTo(const ForgotPasswordPage()),
                              child: Text(context.l10n.faqForgotPassword),
                            ),
                        ],
                        14.height,
                        const LoginTermsText(),

                        if (!apiMode) ...[
                          28.height,
                          const SocialLoginSection(),
                        ],
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

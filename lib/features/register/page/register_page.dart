import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/constants/back_appbar.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/format_phone_number.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/special_text_field.dart';
import 'package:vidsell/features/home/page/home_page.dart';
import 'package:vidsell/features/login/page/login_otp_page.dart';
import 'package:vidsell/features/login/page/login_page.dart';
import 'package:vidsell/features/register/widgets/discard_data_dialog.dart';
import 'package:vidsell/features/register/widgets/field_error.dart';
import 'package:vidsell/features/register/widgets/register_terms_text.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// "Gəlin hesabınızı yaradaq" — final step of the sign-up flow.
/// The backend validates the OTP code together with the registration request.
class RegisterPage extends StatefulWidget {
  final String phoneNumber;
  final String? verificationCode;

  const RegisterPage({
    super.key,
    required this.phoneNumber,
    this.verificationCode,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
  );

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _registrationFailed = false;
  bool _hasOpenedOtpPage = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _clearError(() => _nameError = null));
    _emailController.addListener(() => _clearError(() => _emailError = null));
    _passwordController.addListener(
      () => _clearError(() => _passwordError = null),
    );
    _confirmPasswordController.addListener(
      () => _clearError(() => _confirmPasswordError = null),
    );
  }

  void _clearError(void Function() clear) {
    setState(clear);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinuePressed() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = name.isEmpty ? context.l10n.requiredName : null;
      _emailError = !_emailRegex.hasMatch(email)
          ? context.l10n.invalidEmail
          : null;
      _passwordError = password.length < 8
          ? context.l10n.passwordMinLength(8)
          : null;
      _confirmPasswordError = confirmPassword != password
          ? context.l10n.passwordsMismatch
          : null;
    });

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    final authBloc = context.read<AuthBloc>();
    if (!context.read<AppConfig>().useMockBackend) {
      authBloc.add(
        RegistrationOtpRequested(
          identifier: widget.phoneNumber,
          name: name,
          email: email,
          password: password,
        ),
      );
    } else {
      authBloc.add(
        RegistrationSubmitted(
          identifier: widget.phoneNumber,
          name: name,
          email: email,
          password: password,
          verificationCode: widget.verificationCode ?? '',
        ),
      );
    }
  }

  /// Whether the user has typed anything worth warning about before leaving.
  bool get _hasUnsavedInput =>
      _nameController.text.isNotEmpty ||
      _emailController.text.isNotEmpty ||
      _passwordController.text.isNotEmpty ||
      _confirmPasswordController.text.isNotEmpty;

  /// Handles both the AppBar back arrow and the system back gesture.
  /// Shows a confirmation dialog if there's unsaved input.
  Future<void> _handleBackPressed() async {
    if (!_hasUnsavedInput) {
      context.goBack();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => const DiscardDataDialog(),
    );

    if (shouldLeave == true && mounted) {
      context.read<AuthBloc>().add(const AuthFlowCancelled());
      context.goAndClear(const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state.status == AuthStatus.authenticated) {
          context.goAndClear(const HomePage());
        } else if (state.operation == AuthOperation.otpSent &&
            state.pendingRegistration != null &&
            !_hasOpenedOtpPage) {
          _hasOpenedOtpPage = true;
          context
              .goTo(OtpPage(phoneNumber: widget.phoneNumber))
              .whenComplete(() => _hasOpenedOtpPage = false);
        } else if (state.operation == AuthOperation.failure &&
            state.errorMessage != null) {
          if (state.pendingRegistration != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.displayError ?? state.errorMessage!),
              ),
            );
          } else {
            setState(() => _registrationFailed = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.goBack();
              });
            });
          }
        }
      },
      child: PopScope(
        canPop: !_hasUnsavedInput || _registrationFailed,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _handleBackPressed();
        },
        child: Scaffold(
          backgroundColor: AppColor.primaryColor,
          appBar: BackAppbar(onPressed: _handleBackPressed).appbar,
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  10.height,
                  Text(
                    context.l10n.registerIntro,
                    style: AppTextStyle.primaryText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 22.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.height,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      AppLocalizations.of(context)!.registerDetailsPrompt,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 13.sp,
                        color: AppColor.tertiaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  44.height,

                  Text(
                    context.l10n.phone,
                    style: AppTextStyle.primaryText.copyWith(
                      fontSize: 13.sp,
                      color: AppColor.tertiaryTextColor,
                    ),
                  ),
                  8.height,
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/Vector.svg'),
                      8.width,
                      Text(
                        formatPhoneNumber(widget.phoneNumber),
                        style: AppTextStyle.primaryText.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  20.height,

                  SizedBox(
                    height: 60.h,
                    child: SpecialTextField(
                      hintText: context.l10n.nameAndSurname,
                      controller: _nameController,
                      imagePath: 'assets/icons/icon.svg',
                      hasError: _nameError != null,
                    ),
                  ),
                  FieldError(text: _nameError),

                  14.height,

                  SizedBox(
                    height: 60.h,
                    child: SpecialTextField(
                      hintText: context.l10n.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      imagePath: 'assets/icons/solar_letter-bold.svg',
                      hasError: _emailError != null,
                    ),
                  ),
                  FieldError(text: _emailError),

                  14.height,

                  SizedBox(
                    height: 60.h,
                    child: SpecialTextField(
                      hintText: context.l10n.password,
                      controller: _passwordController,
                      obscureText: true,
                      showObscureToggle: true,
                      imagePath: 'assets/icons/majesticons_lock.svg',
                      hasError: _passwordError != null,
                    ),
                  ),
                  FieldError(text: _passwordError),

                  14.height,

                  SizedBox(
                    height: 60.h,
                    child: SpecialTextField(
                      hintText: context.l10n.repeatPassword,
                      controller: _confirmPasswordController,
                      obscureText: true,
                      showObscureToggle: true,
                      imagePath: 'assets/icons/majesticons_lock.svg',
                      hasError: _confirmPasswordError != null,
                    ),
                  ),
                  FieldError(text: _confirmPasswordError),

                  38.height,
                  const RegisterTermsText(),
                  24.height,

                  AppButton(
                    text: 'Devam et',
                    onPressed: _handleContinuePressed,
                    color: AppColor.bgElavated,
                  ),
                  24.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

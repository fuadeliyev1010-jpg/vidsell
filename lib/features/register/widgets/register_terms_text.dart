import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/cabinet/pages/privacy_policy_page.dart';
import 'package:vidsell/features/cabinet/pages/user_agreement_page.dart';
import 'package:vidsell/l10n/app_localizations.dart';

/// Legal disclaimer under the continue button on the register page.
class RegisterTermsText extends StatelessWidget {
  const RegisterTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final baseStyle = AppTextStyle.primaryText.copyWith(
      fontSize: 12.sp,
      color: AppColor.tertiaryTextColor,
    );
    final linkStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: localizations.termsAgreementLead,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.goTo(const UserAgreementPage()),
            ),
            TextSpan(text: ' ${localizations.termsJoin} '),
            TextSpan(
              text: localizations.privacyPolicy,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.goTo(const PrivacyPolicyPage()),
            ),
            TextSpan(text: localizations.termsAgreementEnd),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

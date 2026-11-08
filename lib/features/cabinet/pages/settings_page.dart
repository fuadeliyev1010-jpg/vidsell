import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/state/app_locale_cubit.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/about_app_page.dart';
import 'package:vidsell/features/cabinet/pages/contact_us_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/pages/offer_contract_page.dart';
import 'package:vidsell/features/cabinet/pages/privacy_policy_page.dart';
import 'package:vidsell/features/cabinet/pages/rules_page.dart';
import 'package:vidsell/features/cabinet/pages/support_page.dart';
import 'package:vidsell/features/cabinet/pages/user_agreement_page.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/cabinet/widgets/log_out_dialog.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/login/page/login_page.dart';
import 'package:vidsell/l10n/app_localizations.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.settingsTitle),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.bgSurfaceColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSettingsTile(
                        iconPath: 'assets/icons/6.svg',
                        title: context.l10n.support,
                        onTap: () {
                          context.goTo(const SupportPage());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/4.svg',
                        title: context.l10n.contactUs,
                        onTap: () {
                          ContactUsBottomSheet.show(context);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/8.svg',
                        title: context.l10n.aboutApp,
                        onTap: () {
                          context.goTo(const AboutAppPage());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/3.svg',
                        title: context.l10n.userAgreement,
                        onTap: () {
                          context.goTo(const UserAgreementPage());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/5.svg',
                        title: context.l10n.rules,
                        onTap: () {
                          context.goTo(const RulesPage());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/7.svg',
                        title: context.l10n.offerAgreement,
                        onTap: () {
                          context.goTo(const OfferContractPage());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/2.svg',
                        title: context.l10n.privacyPolicy,
                        onTap: () {
                          context.goTo(const PrivacyPolicyPage());
                        },
                      ),
                      _buildDivider(),
                      BlocBuilder<AppLocaleCubit, Locale>(
                        builder: (context, locale) {
                          final localizations = AppLocalizations.of(context)!;
                          return _buildSettingsTile(
                            iconPath: 'assets/icons/8.svg',
                            title: localizations.language,
                            trailing: Text(
                              locale.languageCode == 'en'
                                  ? localizations.languageEnglish
                                  : localizations.languageTurkish,
                              style: AppTextStyle.mutedText.copyWith(
                                color: AppColor.tertiaryTextColor,
                                fontSize: 13.sp,
                              ),
                            ),
                            onTap: () => _showLanguagePicker(context),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        iconPath: 'assets/icons/ic_baseline-log-out.svg',
                        title: context.l10n.logout,
                        isDestructive: true,
                        onTap: () async {
                          final authBloc = context.read<AuthBloc>();
                          final shouldLogOut = await LogOutDialog.show(context);
                          if (shouldLogOut == true) {
                            authBloc.add(const AuthLoggedOut());
                            if (context.mounted) {
                              context.goAndClear(const LoginPage());
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final Color textColor = isDestructive
        ? const Color(0xFFFF3B30)
        : Colors.white;
    final Color iconColor = isDestructive
        ? const Color(0xFFFF3B30)
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.5.h),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            14.width,
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.primaryText.copyWith(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ?trailing,
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 50.w, right: 16.w),
      child: Divider(
        color: const Color(0xFF232C3A),
        height: 1.h,
        thickness: 1.h,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final localeCubit = context.read<AppLocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.bgSurfaceColor,
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations.languageEnglish),
                onTap: () {
                  localeCubit.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.languageTurkish),
                onTap: () {
                  localeCubit.setLocale(const Locale('tr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

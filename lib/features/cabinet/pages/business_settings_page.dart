import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/cabinet/pages/about_app_page.dart';
import 'package:vidsell/features/cabinet/pages/business_profile_page.dart';
import 'package:vidsell/features/cabinet/pages/contact_us_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/pages/offer_contract_page.dart';
import 'package:vidsell/features/cabinet/pages/privacy_policy_page.dart';
import 'package:vidsell/features/cabinet/pages/rules_page.dart';
import 'package:vidsell/features/cabinet/pages/support_page.dart';
import 'package:vidsell/features/cabinet/pages/user_agreement_page.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/cabinet/widgets/log_out_dialog.dart';
import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/login/page/login_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessSettingsResult {
  const BusinessSettingsResult({this.account, this.deleted = false});

  final BusinessAccount? account;
  final bool deleted;
}

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key, required this.account});

  final BusinessAccount account;

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  late BusinessAccount _account;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.settingsTitle),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
                children: [
                  _buildActionCard(
                    title: _account.isActive
                        ? context.l10n.storeDisableTemporarily
                        : context.l10n.storeEnableAgain,
                    description: _account.isActive
                        ? context.l10n.storeHiddenDescription
                        : context.l10n.storeVisibleDescription,
                    buttonText: _account.isActive
                        ? context.l10n.storeDisableAction
                        : context.l10n.storeEnableAction,
                    icon: _account.isActive
                        ? Icons.power_settings_new
                        : Icons.power,
                    destructive: _account.isActive,
                    onPressed: _toggleStoreStatus,
                  ),
                  12.height,
                  _buildActionCard(
                    title: context.l10n.storeProfile,
                    description: context.l10n.storeVisibilityHelp,
                    buttonText: context.l10n.viewMyStore,
                    icon: Icons.visibility_outlined,
                    onPressed: () =>
                        context.goTo(BusinessProfilePage(account: _account)),
                  ),
                  12.height,
                  _buildSettingsGroup([
                    _SettingsItem(
                      icon: 'assets/icons/6.svg',
                      title: context.l10n.support,
                      onTap: () => context.goTo(const SupportPage()),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/4.svg',
                      title: context.l10n.contactUs,
                      onTap: () => ContactUsBottomSheet.show(context),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/8.svg',
                      title: context.l10n.aboutApp,
                      onTap: () => context.goTo(const AboutAppPage()),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/3.svg',
                      title: context.l10n.userAgreement,
                      onTap: () => context.goTo(const UserAgreementPage()),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/5.svg',
                      title: context.l10n.rules,
                      onTap: () => context.goTo(const RulesPage()),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/7.svg',
                      title: context.l10n.distanceSalesAgreement,
                      onTap: () => context.goTo(const OfferContractPage()),
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/2.svg',
                      title: context.l10n.privacyPolicy,
                      onTap: () => context.goTo(const PrivacyPolicyPage()),
                    ),
                    _SettingsItem(
                      title: context.l10n.logout,
                      materialIcon: Icons.logout,
                      destructive: true,
                      onTap: _logout,
                    ),
                    _SettingsItem(
                      icon: 'assets/icons/delete_icon.svg',
                      title: context.l10n.accountDelete,
                      destructive: true,
                      onTap: _deleteStore,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    final color = destructive ? AppColor.error : AppColor.activeColor;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          14.height,
          Text(
            description,
            style: AppTextStyle.mutedText.copyWith(
              fontSize: 12.sp,
              height: 1.35,
            ),
          ),
          14.height,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : onPressed,
              icon: Icon(icon, color: color, size: 20.sp),
              label: Text(
                buttonText,
                style: TextStyle(color: color, fontSize: 14.sp),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(52.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                side: BorderSide(color: color, width: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingsItem> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _buildSettingsRow(items[index]),
            if (index < items.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColor.bgSurfaceColor,
                indent: 24.w,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsRow(_SettingsItem item) {
    final color = item.destructive ? AppColor.error : Colors.white;
    return InkWell(
      onTap: item.onTap,
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: [
            if (item.icon case final icon?)
              SvgPicture.asset(
                icon,
                width: 20.r,
                height: 20.r,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else
              Icon(item.materialIcon, color: color, size: 20.sp),
            16.width,
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyle.primaryText.copyWith(
                  color: color,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: item.destructive ? AppColor.error : Colors.grey.shade600,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStoreStatus() async {
    final nextActive = !_account.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColor.bgSurfaceColor,
        title: Text(
          nextActive
              ? context.l10n.storeEnableConfirm
              : context.l10n.storeDisableConfirm,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
        content: Text(
          nextActive
              ? context.l10n.storeEnableConfirmDescription
              : context.l10n.storeDisableConfirmDescription,
          style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              nextActive
                  ? context.l10n.activateNow
                  : context.l10n.storeDeactivate,
              style: TextStyle(
                color: nextActive ? AppColor.activeColor : AppColor.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final draft = _draftFromAccount(_account).copyWith(isActive: nextActive);
      final updated = await context.read<BusinessRepository>().updateBusiness(
        _account.id,
        draft,
      );
      if (mounted) setState(() => _account = updated);
    } on Exception catch (error) {
      if (mounted) {
        _showMessage(context.l10n.storeStatusUpdateFailed('$error'));
      }
    } on StateError catch (error) {
      if (mounted) {
        _showMessage(context.l10n.storeStatusUpdateFailed('$error'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final authBloc = context.read<AuthBloc>();
    final confirmed = await LogOutDialog.show(context);
    if (confirmed != true || !mounted) return;
    authBloc.add(const AuthLoggedOut());
    if (mounted) context.goAndClear(const LoginPage());
  }

  Future<void> _deleteStore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColor.bgSurfaceColor,
        title: Text(
          context.l10n.accountDeleteConfirm,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
        content: Text(
          context.l10n.storeDeleteDescription,
          style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.l10n.storeDelete,
              style: const TextStyle(color: AppColor.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await context.read<BusinessRepository>().deleteBusiness(_account.id);
      if (mounted) {
        context.goBack(const BusinessSettingsResult(deleted: true));
      }
    } on Exception catch (error) {
      if (mounted) _showMessage(context.l10n.storeDeleteFailed('$error'));
    } on StateError catch (error) {
      if (mounted) _showMessage(context.l10n.storeDeleteFailed('$error'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  BusinessAccountDraft _draftFromAccount(BusinessAccount account) =>
      BusinessAccountDraft(
        phoneNumber: account.phoneNumber,
        storeName: account.storeName,
        slogan: account.slogan,
        description: account.description,
        categoryNames: account.categoryNames,
        logoPath: account.logoPath,
        bannerPath: account.bannerPath,
        city: account.city,
        address: account.address,
        alwaysOpen: account.alwaysOpen,
        openDays: account.openDays,
        openingTime: account.openingTime,
        closingTime: account.closingTime,
        email: account.email,
        mainPhone: account.mainPhone,
        additionalPhones: account.additionalPhones,
        shortNumber: account.shortNumber,
        isActive: account.isActive,
      );

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsItem {
  const _SettingsItem({
    this.icon,
    this.materialIcon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  final String? icon;
  final IconData? materialIcon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;
}

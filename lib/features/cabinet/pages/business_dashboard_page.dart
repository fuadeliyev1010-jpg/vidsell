import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/pages/business_edit_profile_page.dart';
import 'package:vidsell/features/cabinet/pages/business_profile_page.dart';
import 'package:vidsell/features/cabinet/pages/business_listings_page.dart';
import 'package:vidsell/features/cabinet/pages/business_statistics_page.dart';
import 'package:vidsell/features/cabinet/pages/business_settings_page.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/cabinet/pages/wallet_page.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key, required this.store});

  final MyStore store;

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  late MyStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _loadStore();
  }

  Future<void> _editProfile() async {
    final updated = await context.goTo<MyStore>(
      BusinessEditProfilePage(
        store: _store,
        draft: context.read<BusinessRepository>().currentDraft,
      ),
    );
    if (!mounted || updated == null) return;
    setState(() => _store = updated);
  }

  Future<void> _openSettings() async {
    final result = await context.goTo<BusinessSettingsResult>(
      BusinessSettingsPage(store: _store),
    );
    if (!mounted) return;
    final latestStore = await context.read<BusinessRepository>().fetchMyStore();
    if (!mounted) return;
    if (latestStore != null) setState(() => _store = latestStore);
    if (result == null) return;
    if (result.deleted) {
      context.goAndClear(const CabinetPage());
      return;
    }
    if (result.store != null) setState(() => _store = result.store!);
  }

  Future<void> _loadStore() async {
    try {
      final repository = context.read<BusinessRepository>();
      final store = await repository.fetchMyStore();
      if (!mounted || store == null) return;
      setState(() => _store = store);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            14.height,
            _buildStoreHeader(),
            46.height,
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
              child: Text(
                _store.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            24.height,
            _buildMenu(context),
            24.height,
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: context.l10n.backToPersonalAccount,
                  icon: Icons.swap_horiz,
                  height: 48.h,
                  color: AppColor.primaryColor,
                  textColor: AppColor.activeColor,
                  side: const BorderSide(color: AppColor.activeColor),
                  onPressed: context.goBack,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildStoreHeader() {
    return SizedBox(
      height: 94.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 94.h,
            child: const ColoredBox(color: Color(0xFF252D3A)),
          ),
          Positioned(
            left: 12.w,
            top: 56.h,
            child: Container(
              width: 74.r,
              height: 74.r,
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                border: Border.all(color: AppColor.primaryColor, width: 3.r),
              ),
              child: _store.logoUrl == null || _store.logoUrl!.isEmpty
                  ? const ColoredBox(color: Color(0xFF252D3A))
                  : Image.network(
                      _store.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Color(0xFF252D3A)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            Icons.storefront_outlined,
            context.l10n.storeInfo,
            onTap: () => context.goTo(BusinessProfilePage.owner(store: _store)),
          ),
          _buildMenuItem(
            Icons.format_list_bulleted,
            context.l10n.myListings,
            onTap: () => context.goTo(const BusinessListingsPage()),
          ),
          _buildMenuItem(
            Icons.account_balance_wallet_outlined,
            context.l10n.wallet,
            onTap: () {
              context.goTo(const WalletPage());
            },
          ),
          _buildMenuItem(
            Icons.bar_chart,
            context.l10n.statistics,
            onTap: () => context.goTo(const BusinessStatisticsPage()),
          ),
          _buildMenuItem(
            Icons.edit_outlined,
            context.l10n.profileEdit,
            onTap: _editProfile,
          ),
          _buildMenuItem(
            Icons.settings_outlined,
            context.l10n.settingsTitle,
            onTap: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Icon(icon, color: AppColor.activeColor, size: 20.sp),
              10.width,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

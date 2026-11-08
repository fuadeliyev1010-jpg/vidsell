import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/state/app_navigation_cubit.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/discover/pages/discover_page.dart';
import 'package:vidsell/features/home/page/home_page.dart';
import 'package:vidsell/features/messages/pages/messages_pages.dart';

import 'package:vidsell/features/new_listing/pages/new_listing_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BottomNavigation extends StatefulWidget {
  final int currentNavIndex;
  const BottomNavigation({super.key, required this.currentNavIndex});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    // Derive the active tab purely from the prop — no cubit emit needed.
    // This avoids mid-frame state changes that cause "deactivated ancestor" errors.
    final activeTab =
        AppNavigationTab.fromIndex(widget.currentNavIndex) ??
        AppNavigationTab.home;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          color: AppColor.bgSurfaceColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      iconPath: 'assets/icons/icon (1).svg',
                      activeIconPath: 'assets/icons/active_home.svg',
                      tab: AppNavigationTab.home,
                      label: context.l10n.listingHome,
                      selectedTab: activeTab,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      iconPath: 'assets/icons/search.svg',
                      activeIconPath: 'assets/icons/search-normal.svg',
                      tab: AppNavigationTab.discover,
                      label: context.l10n.discoverTab,
                      selectedTab: activeTab,
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _buildNavItem(
                      iconPath: 'assets/icons/message.svg',
                      activeIconPath: 'assets/icons/active_message.svg',
                      tab: AppNavigationTab.messages,
                      label: context.l10n.messages,
                      selectedTab: activeTab,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      iconPath: 'assets/icons/profile.svg',
                      activeIconPath: 'assets/icons/active_profile.svg',
                      tab: AppNavigationTab.cabinet,
                      label: context.l10n.userProfile,
                      selectedTab: activeTab,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -18.h,
          child: InkWell(
            onTap: _openNewListing,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.bgSurfaceColor, width: 4.w),
                color: AppColor.activeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 28.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String activeIconPath,
    required String label,
    required AppNavigationTab tab,
    required AppNavigationTab selectedTab,
    int badgeCount = 0,
  }) {
    final isActive = selectedTab == tab;
    final color = isActive ? AppColor.activeColor : Colors.white;

    return InkWell(
      onTap: () => _handleTap(tab),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(isActive ? activeIconPath : iconPath),
                if (badgeCount > 0)
                  Positioned(
                    right: -6.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.w,
                        minHeight: 14.h,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            2.height,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTextStyle.primaryText.copyWith(
                color: color,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNewListing() async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      await context.goTo(const NewListingPage());
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  void _handleTap(AppNavigationTab tab) {
    final currentTab =
        AppNavigationTab.fromIndex(widget.currentNavIndex) ??
        AppNavigationTab.home;
    if (tab == currentTab || _isNavigating) return;

    _isNavigating = true;

    try {
      if (tab == AppNavigationTab.home) {
        context.goAndClear(const HomePage());
      } else if (tab == AppNavigationTab.discover) {
        context.goAndClear(const DiscoverPage());
      } else if (tab == AppNavigationTab.messages) {
        context.goAndClear(const MessagesPage());
      } else if (tab == AppNavigationTab.cabinet) {
        context.goAndClear(const CabinetPage());
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
      rethrow;
    }
  }
}

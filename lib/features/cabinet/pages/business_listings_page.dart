import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/new_listing/pages/new_listing_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessListingsPage extends StatefulWidget {
  const BusinessListingsPage({super.key});

  @override
  State<BusinessListingsPage> createState() => _BusinessListingsPageState();
}

class _BusinessListingsPageState extends State<BusinessListingsPage> {
  int _selectedTab = 0;

  List<String> _tabs(BuildContext context) => [
    context.l10n.active,
    context.l10n.listingStatusPendingPayment,
    context.l10n.listingStatusInactive,
    context.l10n.listingStatusRejected,
    context.l10n.listingStatusUnderReview,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CabinAppbar(title: context.l10n.myListings),
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            16.height,
            _buildTabs(),
            Expanded(child: Center(child: _buildEmptyState())),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs(context).length,
        separatorBuilder: (context, index) => 12.width,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedTab;

          return InkWell(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppColor.activeColor
                        : AppColor.bgSecondary,
                    width: isSelected ? 1.5.h : 1.h,
                  ),
                ),
              ),
              child: Text(
                '${_tabs(context)[index]} (0)',
                maxLines: 1,
                style: AppTextStyle.primaryText.copyWith(
                  color: isSelected
                      ? AppColor.activeColor
                      : AppColor.tertiaryTextColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final title = switch (_selectedTab) {
      0 => context.l10n.emptyActiveListings,
      1 => context.l10n.emptyPendingPaymentListings,
      2 => context.l10n.emptyInactiveListings,
      3 => context.l10n.emptyRejectedListings,
      _ => context.l10n.emptyReviewListings,
    };

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          14.height,
          Text(
            context.l10n.businessListingsPrompt,
            style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
          ),
          14.height,
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: context.l10n.postListingAction,
              icon: Icons.add,
              height: 45.h,
              color: AppColor.bgElevated,
              onPressed: () => context.goTo(const NewListingPage()),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/home/page/home_page.dart';
import 'package:vidsell/features/home/widgets/subscription_shared_widgets.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/features/new_listing/models/listing_submission_details.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class ListingSubmissionSuccessPage extends StatelessWidget {
  const ListingSubmissionSuccessPage({
    super.key,
    required this.listing,
    required this.service,
  });

  final ListingSubmissionDetails listing;
  final String service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SubscriptionHeader(
              title: context.l10n.listingSubmitted,
              onBackTap: context.goBack,
            ),
            10.height,
            Divider(height: 1.h, color: AppColor.bgSecondary),
            14.height,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.success, width: 1.5),
                        color: AppColor.success.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColor.success,
                        size: 36.sp,
                      ),
                    ),
                    16.height,
                    Text(
                      context.l10n.listingModeration,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    16.height,
                    Text(
                      AppLocalizations.of(context)!.listingSuccessDescription,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.mutedText.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14.sp,
                        height: 1.45,
                      ),
                    ),
                    16.height,
                    _buildListingSummary(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 24.h, 12.w, 16.h),
          color: const Color(0xFF191D24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                label: context.l10n.myListings,
                onPressed: () => context.goAndClear(const CabinetPage()),
                primary: true,
              ),
              8.height,
              _buildActionButton(
                label: context.l10n.listingHome,
                onPressed: () => context.goAndClear(const HomePage()),
                primary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF191D24),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          _summaryRow(context.l10n.listingSummary, listing.title),
          if (listing.listingId?.isNotEmpty == true) ...[
            12.height,
            _summaryRow(context.l10n.listingIdLabel, listing.listingId!),
          ],
          12.height,
          _summaryRow(context.l10n.listingService, service),
          12.height,
          _summaryRow(context.l10n.amountToPay, context.l10n.zeroAmountAzn),
          12.height,
          _summaryRow(
            context.l10n.listingStatusLabel,
            _statusLabel(context, listing.status),
            valueColor: const Color(0xFFFFB21A),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, ListingStatus status) =>
      switch (status) {
        ListingStatus.pendingPayment =>
          context.l10n.listingStatusPendingPayment,
        ListingStatus.pendingModeration => context.l10n.moderationStatus,
        ListingStatus.active => context.l10n.active,
        ListingStatus.inactive => context.l10n.listingStatusInactive,
        ListingStatus.rejected => context.l10n.listingStatusRejected,
        ListingStatus.expired => context.l10n.listingStatusExpired,
        ListingStatus.sold => context.l10n.listingStatusSold,
        ListingStatus.deleted => context.l10n.listingStatusDeleted,
        ListingStatus.draft => context.l10n.listingStatusDraft,
        ListingStatus.unknown => context.l10n.listingStatusUnknown,
      };

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool emphasize = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: AppTextStyle.mutedText.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyle.primaryText.copyWith(
              color: valueColor ?? Colors.white,
              fontSize: emphasize ? 14.sp : 12.sp,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF252C37),
                foregroundColor: const Color(0xFFB0B5BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyle.primaryText.copyWith(
                  color: const Color(0xFFB0B5BE),
                  fontSize: 14.sp,
                ),
              ),
            ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/wallet_page.dart';
import 'package:vidsell/features/new_listing/repositories/promotion_repository.dart';
import 'package:vidsell/features/home/widgets/subscription_shared_widgets.dart';
import 'package:vidsell/features/new_listing/pages/boost_subscription_page.dart';
import 'package:vidsell/features/new_listing/pages/premium_subscription_page.dart';
import 'package:vidsell/features/new_listing/pages/listing_submission_success_page.dart';
import 'package:vidsell/features/new_listing/pages/vip_subscription_page.dart';
import 'package:vidsell/models/enums/promotion_type.dart';
import 'package:vidsell/models/product/promote_request.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/promotion/promotion_availability.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

enum _Promotion { vip, premium, boost }

class ListingPromotionPage extends StatefulWidget {
  const ListingPromotionPage({super.key, required this.product});

  final Product product;

  @override
  State<ListingPromotionPage> createState() => _ListingPromotionPageState();
}

class _ListingPromotionPageState extends State<ListingPromotionPage> {
  _Promotion _selectedPromotion = _Promotion.vip;
  late final bool _isApiMode;
  Future<PromotionAvailability>? _availabilityFuture;

  bool get _hasSubscription => _selectedPromotion != _Promotion.boost;

  @override
  void initState() {
    super.initState();
    _isApiMode = !context.read<AppConfig>().useMockBackend;
    if (_isApiMode) {
      _availabilityFuture = context
          .read<PromotionRepository>()
          .fetchAvailability();
    }
  }

  void _finishListing() {
    _finishListingWithService(context.l10n.standardService);
  }

  void _finishListingWithService(String service) {
    context.goAndClear(
      ListingSubmissionSuccessPage(product: widget.product, service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SubscriptionHeader(
              title: context.l10n.newListing,
              onBackTap: context.goBack,
            ),
            10.height,
            Divider(height: 1.h, color: AppColor.bgSecondary),
            14.height,
            Expanded(
              child: _isApiMode
                  ? _buildApiPromotions()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildListingPreview(),
                          16.height,
                          _buildFreeLimit(),
                          16.height,
                          Center(
                            child: Text(
                              context.l10n.freeServicesMonthly,
                              style: AppTextStyle.mutedText.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          16.height,
                          _buildPromotionOption(
                            promotion: _Promotion.vip,
                            icon: Icons.king_bed_rounded,
                            title: context.l10n.vip,
                            detail: context.l10n.quotaRemaining(1, 1),
                            description:
                                context.l10n.listingPromotionVipDescription,
                            iconColor: const Color(0xFFB779FF),
                            onTap: () => _selectPromotion(_Promotion.vip),
                          ),
                          12.height,
                          _buildPromotionOption(
                            promotion: _Promotion.premium,
                            icon: Icons.star_rounded,
                            title: context.l10n.premium,
                            detail: context.l10n.quotaRemaining(1, 1),
                            description:
                                context.l10n.listingPromotionPremiumDescription,
                            iconColor: const Color(0xFFFFB21A),
                            onTap: () => _selectPromotion(_Promotion.premium),
                          ),
                          12.height,
                          _buildPromotionOption(
                            promotion: _Promotion.boost,
                            icon: Icons.trending_up_rounded,
                            title: context.l10n.boostListing,
                            detail: context.l10n.quotaRemaining(3, 3),
                            description:
                                context.l10n.listingPromotionBoostDescription,
                            iconColor: const Color(0xFF26D07C),
                            onTap: () => _selectPromotion(_Promotion.boost),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(top: false, child: _buildFooterActions()),
    );
  }

  void _selectPromotion(_Promotion promotion) {
    setState(() => _selectedPromotion = promotion);
  }

  Widget _buildApiPromotions() {
    return FutureBuilder<PromotionAvailability>(
      future: _availabilityFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.genericError),
                8.height,
                TextButton(
                  onPressed: () => setState(
                    () => _availabilityFuture = context
                        .read<PromotionRepository>()
                        .fetchAvailability(),
                  ),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.activeColor),
          );
        }

        final availability = snapshot.data!;
        final vipPrice = availability.prices['VIP'];
        final premiumPrice = availability.prices['PREMIUM'];
        if (vipPrice == null || premiumPrice == null) {
          return Center(child: Text(context.l10n.genericError));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildListingPreview(),
              16.height,
              _buildFreeDailyQuota(availability.freeDailyQuota),
              16.height,
              _buildPromotionOption(
                promotion: _Promotion.vip,
                icon: Icons.king_bed_rounded,
                title: context.l10n.vip,
                detail: CurrencyFormatter.formatPrice(
                  vipPrice,
                  'TRY',
                  decimalDigits: 2,
                ),
                description: context.l10n.listingPromotionVipDescription,
                iconColor: const Color(0xFFB779FF),
                onTap: () => _selectPromotion(_Promotion.vip),
              ),
              12.height,
              _buildPromotionOption(
                promotion: _Promotion.premium,
                icon: Icons.star_rounded,
                title: context.l10n.premium,
                detail: CurrencyFormatter.formatPrice(
                  premiumPrice,
                  'TRY',
                  decimalDigits: 2,
                ),
                description: context.l10n.listingPromotionPremiumDescription,
                iconColor: const Color(0xFFFFB21A),
                onTap: () => _selectPromotion(_Promotion.premium),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeDailyQuota(int quota) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.freeListingLimit,
              style: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
            ),
          ),
          Text(
            context.l10n.freeDailyPromotions(quota),
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.successLight,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseApiPromotion() async {
    if (widget.product.id.isEmpty) {
      _showApiPromotionError();
      return;
    }

    final promotionType = switch (_selectedPromotion) {
      _Promotion.vip => PromotionType.vip,
      _Promotion.premium => PromotionType.premium,
      _Promotion.boost => null,
    };
    if (promotionType == null) return;

    try {
      await context.read<PromotionRepository>().promoteProduct(
        productId: widget.product.id,
        request: PromoteRequest(promotionType: promotionType, days: 30),
      );
      if (!mounted) return;
      _finishListingWithService(
        promotionType == PromotionType.vip
            ? context.l10n.vip
            : context.l10n.premium,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showApiPromotionError(
        insufficientBalance: error.code == 'ERROR_WALLET_INSUFFICIENT_BALANCE',
      );
    } on Exception {
      if (!mounted) return;
      _showApiPromotionError();
    }
  }

  void _showApiPromotionError({bool insufficientBalance = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            insufficientBalance
                ? context.l10n.walletInsufficientBalance
                : context.l10n.genericError,
          ),
          action: insufficientBalance
              ? SnackBarAction(
                  label: context.l10n.topUpBalance,
                  onPressed: () => context.goTo(const WalletPage()),
                )
              : null,
        ),
      );
  }

  Future<void> _continuePromotion() async {
    if (_isApiMode) {
      await _purchaseApiPromotion();
      return;
    }
    if (_selectedPromotion == _Promotion.vip) {
      await context.goTo(VipSubscriptionPage(product: widget.product));
    } else if (_selectedPromotion == _Promotion.premium) {
      await context.goTo(PremiumSubscriptionPage(product: widget.product));
    } else {
      await context.goTo(BoostSubscriptionPage(product: widget.product));
    }
  }

  Widget _buildListingPreview() {
    final details = [
      widget.product.city,
      widget.product.categoryDisplay,
      widget.product.subcategoryDisplay,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');
    return Container(
      height: 88.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _ListingPhoto(path: widget.product.imageUrls.firstOrNull ?? ''),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                2.height,
                Text(
                  CurrencyFormatter.formatPrice(
                    widget.product.price,
                    widget.product.currency,
                    decimalDigits: 2,
                  ),
                  style: AppTextStyle.primaryText.copyWith(
                    color: AppColor.activeColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeLimit() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.freeListingLimit,
                  style: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.quotaRemaining(2, 3),
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.successLight,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          10.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: 2 / 3,
              minHeight: 6.h,
              backgroundColor: const Color(0xFF2A303B),
              valueColor: const AlwaysStoppedAnimation(AppColor.activeColor),
            ),
          ),
          10.height,
          Text(
            AppLocalizations.of(context)!.freeListingsAfter(1),
            style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionOption({
    required _Promotion promotion,
    required IconData icon,
    required String title,
    required String detail,
    required String description,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final selected = _selectedPromotion == promotion;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        height: 73.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111C26) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColor.activeColor : const Color(0xFF242A34),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF252D3A),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            10.width,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.primaryText.copyWith(
                            color: selected
                                ? AppColor.activeColor
                                : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      8.width,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E3028),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          detail,
                          style: AppTextStyle.primaryText.copyWith(
                            color: AppColor.successLight,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  3.height,
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            8.width,
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColor.activeColor : const Color(0xFF4B5563),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
      color: const Color(0xFF191D24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: _continuePromotion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                _hasSubscription
                    ? _selectedPromotion == _Promotion.vip
                          ? context.l10n.activateVip
                          : context.l10n.activatePremium
                    : context.l10n.listingBoostButton,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          8.height,
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: TextButton(
              onPressed: _finishListing,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF252C37),
                foregroundColor: const Color(0xFFB0B5BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                context.l10n.postOnly,
                style: AppTextStyle.primaryText.copyWith(
                  color: const Color(0xFFB0B5BE),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingPhoto extends StatelessWidget {
  const _ListingPhoto({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7.r),
      child: SizedBox(
        width: 56.w,
        height: 56.h,
        child: path.startsWith('http://') || path.startsWith('https://')
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColor.surfaceHighlight,
      child: Icon(
        Icons.image_outlined,
        color: AppColor.mutedColor,
        size: 20.sp,
      ),
    );
  }
}

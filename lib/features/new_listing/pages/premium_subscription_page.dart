import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/home/widgets/subscription_shared_widgets.dart';
import 'package:vidsell/features/new_listing/models/listing_submission_details.dart';
import 'package:vidsell/features/new_listing/pages/listing_submission_success_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class PremiumSubscriptionPage extends StatelessWidget {
  const PremiumSubscriptionPage({super.key, this.listing});

  final ListingSubmissionDetails? listing;

  @override
  Widget build(BuildContext context) {
    final plans = [
      {'duration': context.l10n.planDays(5), 'price': '17,00'},
      {'duration': context.l10n.planDays(15), 'price': '35,00'},
      {'duration': context.l10n.planDays(30), 'price': '45,00'},
    ];
    return SubscriptionPurchasePage(
      icon: Icons.star,
      iconColor: const Color(0xFFF59E0B),
      title: context.l10n.subscriptionPremium,
      description: context.l10n.premiumSubscriptionDescription,
      limitTitle: context.l10n.premiumFreeLimit,
      plans: plans,
      benefits: const _PremiumBenefits(),
      onBackTap: context.goBack,
      onFreeActivate: () => _activateFree(context),
      onPaidActivate: () => _showPaymentUnavailable(context),
    );
  }

  void _activateFree(BuildContext context) {
    final listing = this.listing;
    if (listing != null) {
      context.goAndClear(
        ListingSubmissionSuccessPage(
          listing: listing,
          service: context.l10n.premiumServiceFree(context.l10n.threeDays),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.premiumActivate)));
    context.goBack();
  }

  void _showPaymentUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.paymentUnavailable)));
  }
}

class _PremiumBenefits extends StatelessWidget {
  const _PremiumBenefits();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        Text(
          context.l10n.included,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10.sp,
          ),
        ),
        SubscriptionBenefitChip(
          icon: Icons.trending_up,
          label: context.l10n.boostDailyBenefit,
          color: const Color(0xFF22C55E),
        ),
        SubscriptionBenefitChip(
          icon: Icons.king_bed,
          label: context.l10n.makeVip,
          color: const Color(0xFF9333EA),
        ),
      ],
    );
  }
}

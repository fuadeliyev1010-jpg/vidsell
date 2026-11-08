import 'package:flutter/material.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/home/widgets/subscription_shared_widgets.dart';
import 'package:vidsell/features/new_listing/models/listing_submission_details.dart';
import 'package:vidsell/features/new_listing/pages/listing_submission_success_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BoostSubscriptionPage extends StatelessWidget {
  const BoostSubscriptionPage({super.key, this.listing});

  final ListingSubmissionDetails? listing;

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'duration':
            '${context.l10n.planTimes(3)} (${context.l10n.everyHours(8)})',
        'price': '1,50',
      },
      {
        'duration':
            '${context.l10n.planTimes(9)} (${context.l10n.everyHours(8)})',
        'price': '2,00',
      },
      {
        'duration':
            '${context.l10n.planTimes(15)} (${context.l10n.everyHours(8)})',
        'price': '3,00',
      },
    ];
    return SubscriptionPurchasePage(
      icon: Icons.trending_up,
      iconColor: const Color(0xFF22C55E),
      title: context.l10n.boostListing,
      description: context.l10n.boostSubscriptionDescription,
      limitTitle: context.l10n.boostFreeLimit,
      plans: plans,
      freePlanLabel: context.l10n.planTimes(1),
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
          service: context.l10n.boostServiceFree(1),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.boostActivate)));
    context.goBack();
  }

  void _showPaymentUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.paymentUnavailable)));
  }
}

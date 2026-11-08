import 'package:flutter/material.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/home/widgets/subscription_shared_widgets.dart';
import 'package:vidsell/features/new_listing/models/listing_submission_details.dart';
import 'package:vidsell/features/new_listing/pages/listing_submission_success_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class VipSubscriptionPage extends StatelessWidget {
  const VipSubscriptionPage({super.key, this.listing});

  final ListingSubmissionDetails? listing;

  @override
  Widget build(BuildContext context) {
    final plans = [
      {'duration': context.l10n.planDays(5), 'price': '7,00'},
      {'duration': context.l10n.planDays(15), 'price': '16,00'},
      {'duration': context.l10n.planDays(30), 'price': '25,00'},
    ];
    return SubscriptionPurchasePage(
      icon: Icons.king_bed,
      iconColor: const Color(0xFF9333EA),
      title: context.l10n.subscriptionVip,
      description: context.l10n.vipSubscriptionDescription,
      limitTitle: context.l10n.vipFreeLimit,
      plans: plans,
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
          service: context.l10n.vipServiceFree(context.l10n.threeDays),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.vipActivate)));
    context.goBack();
  }

  void _showPaymentUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.paymentUnavailable)));
  }
}

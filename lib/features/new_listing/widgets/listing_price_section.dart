import 'package:flutter/material.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/features/new_listing/widgets/listing_form_components.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ListingPriceSection extends StatelessWidget {
  const ListingPriceSection({super.key, required this.priceController});

  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return ListingTextField(
      controller: priceController,
      label: context.l10n.listingPriceLabel,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColor.tertiaryTextColor,
        size: 20,
      ),
    );
  }
}

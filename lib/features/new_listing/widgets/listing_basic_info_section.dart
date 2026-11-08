import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/new_listing/widgets/listing_form_components.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ListingBasicInfoSection extends StatelessWidget {
  const ListingBasicInfoSection({
    super.key,
    required this.brandController,
    required this.modelController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: brandController,
          builder: (context, value, _) => Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: listingFieldDecoration,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: brandController,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                    decoration: listingInputDecoration(
                      label: context.l10n.productBrand,
                    ),
                  ),
                ),
                if (value.text.isNotEmpty)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: brandController.clear,
                    icon: Icon(
                      Icons.close,
                      color: AppColor.tertiaryTextColor,
                      size: 18.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
        12.height,
        ListingTextField(
          controller: modelController,
          label: context.l10n.productModel,
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColor.tertiaryTextColor,
            size: 20,
          ),
        ),
      ],
    );
  }
}

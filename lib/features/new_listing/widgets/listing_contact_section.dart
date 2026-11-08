import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/widgets/listing_form_components.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ListingContactSection extends StatelessWidget {
  const ListingContactSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.contactMethod,
    required this.onContactMethodChanged,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final ContactMethod contactMethod;
  final ValueChanged<ContactMethod> onContactMethodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactTextField(
          controller: nameController,
          label: context.l10n.listingFieldName,
        ),
        24.height,
        ListingSectionHeader(context.l10n.listingContactMethod),
        12.height,
        ListingRadioRow(
          label: context.l10n.callsAndMessages,
          selected: contactMethod == ContactMethod.callsAndMessages,
          onTap: () => onContactMethodChanged(ContactMethod.callsAndMessages),
        ),
        ListingRadioRow(
          label: context.l10n.callsOnly,
          selected: contactMethod == ContactMethod.callsOnly,
          onTap: () => onContactMethodChanged(ContactMethod.callsOnly),
        ),
        ListingRadioRow(
          label: context.l10n.messagesOnlyHiddenNumber,
          selected: contactMethod == ContactMethod.messagesOnly,
          onTap: () => onContactMethodChanged(ContactMethod.messagesOnly),
        ),
        24.height,
        _ContactTextField(
          controller: emailController,
          label: context.l10n.email,
          keyboardType: TextInputType.emailAddress,
        ),
        12.height,
        _ContactTextField(
          controller: phoneController,
          label: context.l10n.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _ContactTextField extends StatelessWidget {
  const _ContactTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: listingFieldDecoration,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: listingInputDecoration(label: label),
      ),
    );
  }
}

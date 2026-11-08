import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class StaticContentPage extends StatelessWidget {
  const StaticContentPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<({String heading, String body})> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: context.goBack,
        ),
        title: Text(
          title,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vidsell',
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.activeColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18.h),
              ...sections.expand(
                (section) => [
                  Text(
                    section.heading,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    section.body,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<({String heading, String body})> aboutAppSections(AppLocalizations l10n) =>
    [
      (heading: l10n.aboutWhatTitle, body: l10n.aboutWhatBody),
      (heading: l10n.aboutFeaturesTitle, body: l10n.aboutFeaturesBody),
      (heading: l10n.aboutVersionTitle, body: l10n.aboutVersionBody),
    ];

List<({String heading, String body})> privacyPolicySections(
  AppLocalizations l10n,
) => [
  (
    heading: l10n.privacyDataCollectedTitle,
    body: l10n.privacyDataCollectedBody,
  ),
  (heading: l10n.privacyDataUseTitle, body: l10n.privacyDataUseBody),
  (heading: l10n.privacyRetentionTitle, body: l10n.privacyRetentionBody),
  (heading: l10n.privacyRightsTitle, body: l10n.privacyRightsBody),
];

List<({String heading, String body})> userAgreementSections(
  AppLocalizations l10n,
) => [
  (heading: l10n.agreementUseTitle, body: l10n.agreementUseBody),
  (heading: l10n.agreementListingsTitle, body: l10n.agreementListingsBody),
  (heading: l10n.agreementMessagesTitle, body: l10n.agreementMessagesBody),
  (
    heading: l10n.agreementRestrictionsTitle,
    body: l10n.agreementRestrictionsBody,
  ),
];

List<({String heading, String body})> offerContractSections(
  AppLocalizations l10n,
) => [
  (heading: l10n.offerPartiesTitle, body: l10n.offerPartiesBody),
  (heading: l10n.offerPlatformRoleTitle, body: l10n.offerPlatformRoleBody),
  (heading: l10n.offerPaidServicesTitle, body: l10n.offerPaidServicesBody),
  (heading: l10n.offerChangesTitle, body: l10n.offerChangesBody),
];

List<({String heading, String body})> rulesSections(AppLocalizations l10n) => [
  (heading: l10n.rulesProhibitedTitle, body: l10n.rulesProhibitedBody),
  (heading: l10n.rulesQualityTitle, body: l10n.rulesQualityBody),
  (heading: l10n.rulesCommunicationTitle, body: l10n.rulesCommunicationBody),
  (heading: l10n.rulesComplaintsTitle, body: l10n.rulesComplaintsBody),
];

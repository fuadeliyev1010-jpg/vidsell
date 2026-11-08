import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int _selectedCategoryIndex = 0;
  int? _expandedFaqIndex =
      3; // Fourth item expanded by default to match screenshot

  List<String> get _categories => [
    context.l10n.supportPopularQuestions,
    context.l10n.supportListing,
    context.l10n.supportPersonalCabinet,
    context.l10n.supportPostingListing,
  ];

  List<List<String>> get _faqTitlesByCategory => [
    [
      context.l10n.faqCreateAccount,
      context.l10n.faqEditListing,
      context.l10n.faqFindMessages,
      context.l10n.faqReportListing,
    ],
    [
      context.l10n.faqPostListing,
      context.l10n.faqPublishTime,
      context.l10n.faqDeleteListing,
      context.l10n.faqListingRejected,
    ],
    [
      context.l10n.faqEditProfile,
      context.l10n.faqVerifyPhone,
      context.l10n.faqForgotPassword,
      context.l10n.faqDeleteAccount,
    ],
    [
      context.l10n.faqAddMedia,
      context.l10n.faqSetPrice,
      context.l10n.faqChooseCategory,
      context.l10n.faqModeration,
    ],
  ];

  List<String> get _faqAnswers => [
    context.l10n.faqAccountAnswer,
    context.l10n.faqListingAnswer,
    context.l10n.faqProfileAnswer,
    context.l10n.faqQualityAnswer,
  ];

  List<String> get _faqTitles => _faqTitlesByCategory[_selectedCategoryIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.support),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              _buildCategoryChips(),
              16.height,
              _buildFaqSection(),
              16.height,
              _buildContactSection(),
              24.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.activeColor
                      : AppColor.bgSurfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _faqTitles.length,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Divider(
            color: const Color(0xFF232C3A),
            height: 1.h,
            thickness: 1.h,
          ),
        ),
        itemBuilder: (context, index) {
          final isExpanded = _expandedFaqIndex == index;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedFaqIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _faqTitles[index],
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.close_rounded : Icons.add_rounded,
                        color: Colors.grey.shade500,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.h,
                  ),
                  child: Text(
                    _faqAnswers[_selectedCategoryIndex],
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.questionUnanswered,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.height,
          _buildContactTile(
            iconPath: 'assets/icons/4.svg',
            title: context.l10n.call,
            onTap: () =>
                _openExternal(Uri(scheme: 'tel', path: '+994123456789')),
          ),
          _buildContactDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline_messages.svg',
            title: context.l10n.messageUs,
            onTap: () => _openExternal(
              Uri(scheme: 'mailto', path: 'support@vidsell.az'),
            ),
          ),
          _buildContactDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline-facebook.svg',
            title: 'Facebook',
            onTap: () =>
                _openExternal(Uri.parse('https://www.facebook.com/vidsell')),
          ),
          _buildContactDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline_instagram.svg',
            title: 'Instagram',
            onTap: () =>
                _openExternal(Uri.parse('https://www.instagram.com/vidsell')),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 20.sp,
              height: 20.sp,
            ),
            12.width,
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade600,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.contactLinkFailed)));
    }
  }

  Widget _buildContactDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 32.w),
      child: Divider(
        color: const Color(0xFF232C3A),
        height: 1.h,
        thickness: 1.h,
      ),
    );
  }
}

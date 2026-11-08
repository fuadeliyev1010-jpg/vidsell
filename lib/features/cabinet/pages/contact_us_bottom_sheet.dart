import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ContactUsBottomSheet extends StatelessWidget {
  const ContactUsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ContactUsBottomSheet(),
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    Navigator.pop(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.contactLinkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3B4656),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          16.height,
          // Header Row with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.questionUnanswered,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade500,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          16.height,
          _buildContactTile(
            iconPath: 'assets/icons/4.svg',
            title: context.l10n.call,
            onTap: () {
              _open(context, Uri(scheme: 'tel', path: '+994123456789'));
            },
          ),
          _buildDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline_messages.svg',
            title: context.l10n.messageUs,
            onTap: () {
              _open(context, Uri(scheme: 'mailto', path: 'support@vidsell.az'));
            },
          ),
          _buildDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline-facebook.svg',
            title: 'Facebook',
            onTap: () {
              _open(context, Uri.parse('https://www.facebook.com/vidsell'));
            },
          ),
          _buildDivider(),
          _buildContactTile(
            iconPath: 'assets/icons/ic_baseline_instagram.svg',
            title: 'Instagram',
            onTap: () {
              _open(context, Uri.parse('https://www.instagram.com/vidsell'));
            },
          ),
          12.height,
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
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 20.r,
              height: 20.r,
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

  Widget _buildDivider() {
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

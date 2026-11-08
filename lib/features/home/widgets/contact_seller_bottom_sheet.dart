import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/call_seller.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/messages/utils/open_seller_chat.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ContactSellerBottomSheet extends StatelessWidget {
  const ContactSellerBottomSheet({
    super.key,
    required this.listing,
    this.phoneNumber = '+994 50 123 45 67',
  });

  final HomeListing listing;
  final String phoneNumber;

  static Future<void> show(
    BuildContext context, {
    required HomeListing listing,
    String phoneNumber = '+994 50 123 45 67',
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          ContactSellerBottomSheet(listing: listing, phoneNumber: phoneNumber),
    );
  }

  String get _cleanPhone => phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

  Future<void> _openWhatsApp(BuildContext context) async {
    final cleanDigits = _cleanPhone.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$cleanDigits');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.whatsappUnavailable)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.whatsappUnavailable)),
        );
      }
    }
  }

  void _copyAndNotify(BuildContext context, {String? message}) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? context.l10n.sellerNumberCopied(phoneNumber)),
        duration: const Duration(seconds: 2),
      ),
    );
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
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.contactSeller,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade400,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          14.height,

          // Seller card summary
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColor.activeColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: AppColor.activeColor,
                    size: 22.sp,
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.sellerName.isNotEmpty
                            ? listing.sellerName
                            : listing.sellerHandle,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      2.height,
                      Text(
                        listing.sellerHandle,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  listing.price,
                  style: AppTextStyle.primaryText.copyWith(
                    color: AppColor.activeColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          18.height,

          // Call button tile
          _buildActionTile(
            icon: Icons.phone_in_talk_rounded,
            iconColor: AppColor.success,
            title: context.l10n.call,
            subtitle: phoneNumber,
            trailingWidget: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.l10n.call,
                style: TextStyle(
                  color: AppColor.success,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              callSeller(context, listing.phoneNumber);
            },
          ),
          _buildDivider(),

          // WhatsApp button tile
          _buildActionTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: const Color(0xFF25D366),
            title: context.l10n.whatsappMessage,
            subtitle: context.l10n.openDirectChat,
            trailingWidget: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'WhatsApp',
                style: TextStyle(
                  color: const Color(0xFF25D366),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _openWhatsApp(context);
            },
          ),
          _buildDivider(),

          // Copy number tile
          _buildActionTile(
            icon: Icons.copy_rounded,
            iconColor: Colors.white70,
            title: context.l10n.copyNumber,
            subtitle: phoneNumber,
            onTap: () {
              _copyAndNotify(context);
              Navigator.pop(context);
            },
          ),
          _buildDivider(),

          // In-app chat tile
          _buildActionTile(
            icon: Icons.send_rounded,
            iconColor: AppColor.activeColor,
            title: context.l10n.inAppMessage,
            subtitle: context.l10n.chatWithVidsell,
            onTap: () {
              Navigator.pop(context);
              openSellerChat(context, listing);
            },
          ),
          12.height,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  2.height,
                  Text(
                    subtitle,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else
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
      padding: EdgeInsets.only(left: 52.w),
      child: Divider(
        color: const Color(0xFF232C3A),
        height: 1.h,
        thickness: 1.h,
      ),
    );
  }
}

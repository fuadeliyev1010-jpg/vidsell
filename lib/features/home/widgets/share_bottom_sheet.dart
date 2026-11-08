import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// Call this to show the branded share bottom sheet.
///
/// Example:
/// ```dart
/// showShareBottomSheet(
///   context,
///   sellerName: 'TechStore',
///   link: 'https://vidsell.az/listing/12345',
/// );
/// ```
Future<void> showShareBottomSheet(
  BuildContext context, {
  required String sellerName,
  required String link,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ShareBottomSheet(sellerName: sellerName, link: link),
  );
}

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({
    super.key,
    required this.sellerName,
    required this.link,
  });

  final String sellerName;
  final String link;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColor.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
            40.height,
            Text(
              context.l10n.shareListingTitle(sellerName),
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            40.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ShareOption(
                    label: context.l10n.shareAction,
                    child: SvgPicture.asset(
                      'assets/icons/Vector2.svg',
                      height: 22.h,
                      width: 22.w,
                    ),
                    onTap: () => _shareGeneric(context),
                  ),
                  24.width,
                  _ShareOption(
                    label: context.l10n.copyLinkAction,
                    child: SvgPicture.asset(
                      'assets/icons/solar_link-bold.svg',
                      height: 22.h,
                      width: 22.w,
                    ),
                    onTap: () => _copyLink(context),
                  ),
                  24.width,
                  _ShareOption(
                    label: 'WhatsApp',
                    background: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/icons/selfhst_whatsapp.svg',
                      height: 52.h,
                      width: 52.w,
                    ),
                    onTap: () => _openWhatsApp(context),
                  ),
                  24.width,
                  _ShareOption(
                    label: 'Telegram',
                    background: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/icons/logos_telegram.svg',
                      height: 52.h,
                      width: 52.w,
                    ),
                    onTap: () => _openTelegram(context),
                  ),
                  24.width,
                  _ShareOption(
                    label: 'Instagram',
                    background: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/icons/instagram-2-1-logo-svgrepo-com.svg',
                      height: 52.h,
                      width: 52.w,
                    ),
                    onTap: () => _openInstagram(context),
                  ),
                ],
              ),
            ),
            24.height,
          ],
        ),
      ),
    );
  }

  String _shareText(BuildContext context) =>
      context.l10n.shareListingText(sellerName, link);

  Future<void> _shareGeneric(BuildContext context) async {
    Navigator.of(context).pop();
    await SharePlus.instance.share(ShareParams(text: _shareText(context)));
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.linkCopied)));
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_shareText(context))}',
    );
    await _launch(context, uri);
  }

  Future<void> _openTelegram(BuildContext context) async {
    final uri = Uri.parse(
      'https://t.me/share/url?url=${Uri.encodeComponent(link)}'
      '&text=${Uri.encodeComponent(_shareText(context))}',
    );
    await _launch(context, uri);
  }

  Future<void> _openInstagram(BuildContext context) async {
    // Instagram doesn't support pre-filled link/text sharing via URL scheme.
    // The best we can do is deep-link into the app (if installed) and let
    // the user paste the link themselves, or fall back to the native share
    // sheet so they can pick "Instagram" -> "Story"/"Direct" from there.
    final appUri = Uri.parse('instagram://app');
    final shareText = _shareText(context);
    final linkCopiedText = context.l10n.linkCopied;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final canUseContext = context.mounted;
    navigator.pop();
    if (await canLaunchUrl(appUri)) {
      await Clipboard.setData(ClipboardData(text: link));
      if (canUseContext && messenger != null) {
        messenger.showSnackBar(SnackBar(content: Text(linkCopiedText)));
      }
      await launchUrl(appUri);
    } else {
      await SharePlus.instance.share(ShareParams(text: shareText));
    }
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final appCouldNotOpenText = context.l10n.appCouldNotOpen;
    final navigator = Navigator.of(context);
    navigator.pop();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(appCouldNotOpenText)));
    }
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.label,
    required this.child,
    required this.onTap,
    this.background = AppColor.bgElavated,
  });
  final String label;
  final Widget child;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: child,
          ),
          6.height,
          Text(
            label,
            style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

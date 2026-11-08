import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

Future<void> callSeller(BuildContext context, String? phoneNumber) async {
  final normalizedPhone = phoneNumber?.trim();
  final phone = normalizedPhone == null || normalizedPhone.isEmpty
      ? '+994 50 123 45 67'
      : normalizedPhone;
  final dialablePhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri(scheme: 'tel', path: dialablePhone);

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.callUnavailable)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.callUnavailable)));
    }
  }
}

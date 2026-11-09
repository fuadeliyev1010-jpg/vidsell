import 'package:flutter/widgets.dart';
import 'package:vidsell/l10n/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Shorthand for `AppLocalizations.of(context)!`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppLocalizationsErrorMessages on AppLocalizations {
  String localizedAuthError(String? code) => switch (code?.toUpperCase()) {
    'INVALID_OTP' || 'INVALID_VERIFICATION_CODE' => invalidOtpCode,
    'ACCOUNT_ALREADY_REGISTERED' => accountAlreadyRegistered,
    'IDENTIFIER_REQUIRED' => loginIdentifierRequired,
    'CONNECTIONTIMEOUT' || 'RECEIVETIMEOUT' || 'SENDTIMEOUT' => serverTimeout,
    'CONNECTIONERROR' => serverUnavailable,
    _ => authRequestFailed,
  };
}

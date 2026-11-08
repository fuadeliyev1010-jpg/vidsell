import 'package:flutter/widgets.dart';
import 'package:vidsell/l10n/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Shorthand for `AppLocalizations.of(context)!`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppLocalizationsErrorMessages on AppLocalizations {
  String localizedAuthError(String? message) => switch (message?.trim()) {
    'Telefon numarası veya e-posta gereklidir.' ||
    'Enter your phone number or email address' => loginIdentifierRequired,
    'Please enter a valid phone number or email address' =>
      loginIdentifierInvalid,
    'Doğrulama kodu geçersiz.' ||
    'Invalid verification code.' => invalidOtpCode,
    'Bu hesap zaten kayıtlıdır.' ||
    'This account is already registered.' => accountAlreadyRegistered,
    'The server took too long to respond.' => serverTimeout,
    'Unable to connect to the server.' => serverUnavailable,
    'The request could not be completed.' => requestFailed,
    _ => authRequestFailed,
  };
}

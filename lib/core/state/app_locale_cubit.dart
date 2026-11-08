import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit() : super(const Locale('tr'));

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' && locale.languageCode != 'tr') {
      return;
    }
    if (locale == state) return;
    emit(Locale(locale.languageCode));
  }
}

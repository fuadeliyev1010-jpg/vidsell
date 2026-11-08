import 'package:flutter_bloc/flutter_bloc.dart';

/// Represents the persistent bottom navigation tabs.
///
/// Note: Index 2 is intentionally reserved for the center "New Listing" action
/// button which launches [NewListingPage] modally rather than switching tabs.
enum AppNavigationTab {
  home(0),
  discover(1),
  messages(3),
  cabinet(4);

  const AppNavigationTab(this.tabIndex);

  final int tabIndex;

  static AppNavigationTab? fromIndex(int index) {
    for (final tab in AppNavigationTab.values) {
      if (tab.tabIndex == index) return tab;
    }
    return null;
  }
}

class AppNavigationCubit extends Cubit<AppNavigationTab> {
  AppNavigationCubit() : super(AppNavigationTab.home);

  bool selectIndex(int index) {
    final tab = AppNavigationTab.fromIndex(index);
    if (tab == null || tab == state) return false;

    emit(tab);
    return true;
  }
}

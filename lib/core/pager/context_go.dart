import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/models/product/product.dart';

extension ContextGo on BuildContext {
  String _pageLocation(Widget page) =>
      '/page/${Uri.encodeComponent(page.runtimeType.toString())}';

  Future<T?> goTo<T extends Object?>(
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    debugPrint('[Navigation] push ${page.runtimeType}');
    return GoRouter.of(this).push<T>(
      _pageLocation(page),
      extra: RoutedPage(page, fullscreenDialog: fullscreenDialog),
    );
  }

  Future<void> goToListingPromotion({required Product product}) {
    debugPrint('[Navigation] push ListingPromotionPage');
    return GoRouter.of(this).push<void>('/listing-promotion', extra: product);
  }

  void goReplace(Widget page) {
    debugPrint('[Navigation] replace with ${page.runtimeType}');
    GoRouter.of(
      this,
    ).pushReplacement<void>(_pageLocation(page), extra: RoutedPage(page));
  }

  void goAndClear(Widget page) {
    debugPrint('[Navigation] go to ${page.runtimeType} and clear stack');
    GoRouter.of(this).go(_pageLocation(page), extra: RoutedPage(page));
  }

  void goRoot() {
    debugPrint('[Navigation] go to root');
    GoRouter.of(this).go('/');
  }

  void goBack<T extends Object?>([T? result]) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      debugPrint('[Navigation] pop');
      router.pop<T>(result);
    }
  }
}

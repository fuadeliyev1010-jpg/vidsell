import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/pager/app_router.dart';

extension ContextGo on BuildContext {
  String _pageLocation(Widget page) =>
      '/page/${Uri.encodeComponent(page.runtimeType.toString())}';

  Future<T?> goTo<T extends Object?>(
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    return GoRouter.of(this).push<T>(
      _pageLocation(page),
      extra: RoutedPage(page, fullscreenDialog: fullscreenDialog),
    );
  }

  Future<void> goToListingPromotion({
    required String title,
    required String price,
    required String city,
    required String category,
    required String subcategory,
    required String image,
    String? listingId,
    String? status,
  }) {
    final location = Uri(
      path: '/listing-promotion',
      queryParameters: {
        'title': title,
        'price': price,
        'city': city,
        'category': category,
        'subcategory': subcategory,
        'image': image,
        'listingId': ?listingId,
        'status': ?status,
      },
    );
    return GoRouter.of(this).push<void>(location.toString());
  }

  void goReplace(Widget page) {
    GoRouter.of(
      this,
    ).pushReplacement<void>(_pageLocation(page), extra: RoutedPage(page));
  }

  void goAndClear(Widget page) {
    GoRouter.of(this).go(_pageLocation(page), extra: RoutedPage(page));
  }

  void goRoot() {
    GoRouter.of(this).go('/');
  }

  void goBack<T extends Object?>([T? result]) {
    final router = GoRouter.of(this);
    if (router.canPop()) router.pop<T>(result);
  }
}

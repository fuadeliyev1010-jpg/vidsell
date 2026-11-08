import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/constants/app_color.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/features/auth/widgets/auth_gate.dart';
import 'package:vidsell/features/auth/widgets/location_permission_gate.dart';
import 'package:vidsell/features/new_listing/pages/listing_promotion_page.dart';
import 'package:vidsell/models/product/product.dart';

GoRoute routedPageRoute() {
  return GoRoute(
    path: '/page/:pageType',
    redirect: (context, state) {
      final page = state.extra;
      if (page is RoutedPage || page is Widget) return null;
      return '/';
    },
    pageBuilder: (context, state) {
      final page = state.extra;
      if (page is RoutedPage) {
        return MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: page.fullscreenDialog,
          child: page.child,
        );
      }
      if (page is Widget) {
        return MaterialPage<void>(key: state.pageKey, child: page);
      }
      return MaterialPage<void>(
        key: state.pageKey,
        child: const _InvalidPageRoute(),
      );
    },
  );
}

GoRoute listingPromotionRoute() {
  return GoRoute(
    path: '/listing-promotion',
    builder: (context, state) {
      final product = state.extra;
      if (product is! Product) return const _InvalidPageRoute();
      return ListingPromotionPage(product: product);
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const LocationPermissionGate(child: AuthGate()),
    ),
    listingPromotionRoute(),
    routedPageRoute(),
  ],
  errorBuilder: (context, state) => const _InvalidPageRoute(),
);

class RoutedPage {
  const RoutedPage(this.child, {this.fullscreenDialog = false});

  final Widget child;
  final bool fullscreenDialog;
}

class _InvalidPageRoute extends StatelessWidget {
  const _InvalidPageRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.appError,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

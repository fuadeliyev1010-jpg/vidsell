import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/features/auth/widgets/auth_gate.dart';
import 'package:vidsell/features/auth/widgets/location_permission_gate.dart';
import 'package:vidsell/features/new_listing/pages/listing_promotion_page.dart';

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
      final parameters = state.uri.queryParameters;
      final title = parameters['title'];
      final price = parameters['price'];
      final city = parameters['city'];
      final category = parameters['category'];
      final subcategory = parameters['subcategory'];
      final image = parameters['image'];
      if (title == null ||
          price == null ||
          city == null ||
          category == null ||
          subcategory == null ||
          image == null) {
        return const _InvalidPageRoute();
      }

      return ListingPromotionPage(
        title: title,
        price: price,
        city: city,
        categoryName: category,
        subcategoryName: subcategory,
        imagePath: image,
        listingId: parameters['listingId'],
        status: ListingStatus.parse(parameters['status']),
      );
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/cabinet/pages/wallet_page.dart';
import 'package:vidsell/features/cabinet/repositories/mock_status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/common/api_error.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/public_store_profile.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/user/user.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';

void main() {
  testWidgets('cabinet sections show independent errors and retry codes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final listings = _PartialFailureListingsRepository();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, child) => RepositoryProvider<BusinessRepository>.value(
          value: _FailingStoreRepository(),
          child: RepositoryProvider<UserListingRepository>.value(
            value: listings,
            child: RepositoryProvider<StatusCountRepository>.value(
              value: MockStatusCountRepository(),
              child: MaterialApp(
                locale: const Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: CabinetPage(
                  profileRepository: _FailingProfileRepository(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry (PROFILE_DOWN)'), findsOneWidget);
    expect(find.text('Retry (STORE_DOWN)'), findsOneWidget);
    expect(find.text('Try again (ACTIVE_DOWN)'), findsOneWidget);
    expect(
      listings.requestedStatuses,
      containsAll([
        ProductStatus.active,
        ProductStatus.pendingPayment,
        ProductStatus.inactive,
        ProductStatus.sold,
        ProductStatus.rejected,
        ProductStatus.underReview,
      ]),
    );

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Could not load listings'), findsNothing);
    expect(find.text('Try again (ACTIVE_DOWN)'), findsNothing);
  });

  testWidgets('wallet balance and transactions have independent retry codes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, child) => RepositoryProvider<WalletRepository>.value(
          value: _FailingWalletRepository(),
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WalletPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry (BALANCE_DOWN)'), findsOneWidget);
    expect(find.text('Retry (TRANSACTIONS_DOWN)'), findsOneWidget);
  });
}

class _FailingProfileRepository implements ProfileRepository {
  @override
  Future<User> fetchProfile() async => throw const ApiException(
    'Could not load profile.',
    apiError: ApiError(code: 'PROFILE_DOWN'),
  );

  @override
  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
    String? avatarPath,
    bool removeAvatar = false,
  }) async => throw UnimplementedError();
}

class _PartialFailureListingsRepository implements UserListingRepository {
  final requestedStatuses = <ProductStatus?>[];

  @override
  Future<List<Product>> fetchMyListings({ProductStatus? status}) async {
    requestedStatuses.add(status);
    if (status == ProductStatus.active) {
      throw const ApiException(
        'Could not load active listings.',
        apiError: ApiError(code: 'ACTIVE_DOWN'),
      );
    }
    return const [];
  }

  @override
  Future<void> deleteListing(String listingId) async {}

  @override
  Future<void> updateListingStatus(
    String listingId,
    ProductStatus status,
  ) async {}
}

class _FailingStoreRepository implements BusinessRepository {
  final _delegate = MockBusinessRepository.instance;

  @override
  StoreDraft? get currentDraft => _delegate.currentDraft;

  @override
  Future<MyStore> createStoreApplication(StoreDraft draft) =>
      _delegate.createStoreApplication(draft);

  @override
  Future<MyStore> updateMyStore(StoreDraft draft) =>
      _delegate.updateMyStore(draft);

  @override
  Future<MyStore> deactivateMyStore() => _delegate.deactivateMyStore();

  @override
  Future<MyStore> reactivateMyStore() => _delegate.reactivateMyStore();

  @override
  Future<void> deleteMyStore() => _delegate.deleteMyStore();

  @override
  Future<MyStore?> fetchMyStore() async => throw const ApiException(
    'Could not load store.',
    apiError: ApiError(code: 'STORE_DOWN'),
  );

  @override
  Future<PublicStoreProfile?> fetchPublicStore(String sellerId) =>
      _delegate.fetchPublicStore(sellerId);

  @override
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  }) => _delegate.fetchPublicStoreProducts(sellerId, page: page);

  @override
  Future<StoreStatistics> fetchMyStoreStatistics() =>
      _delegate.fetchMyStoreStatistics();
}

class _FailingWalletRepository implements WalletRepository {
  @override
  Future<WalletBalance> fetchWallet() async => throw const ApiException(
    'Could not load balance.',
    apiError: ApiError(code: 'BALANCE_DOWN'),
  );

  @override
  Future<List<WalletTransaction>> fetchTransactions() async =>
      throw const ApiException(
        'Could not load transactions.',
        apiError: ApiError(code: 'TRANSACTIONS_DOWN'),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

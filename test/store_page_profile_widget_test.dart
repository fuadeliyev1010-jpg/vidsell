import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/features/home/page/store_page.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/models/enums/seller_type.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/public_store_profile.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  testWidgets('individual profile renders no store stats or contact details', (
    tester,
  ) async {
    final following = FollowingCubit(MockEngagementRepository.instance);
    addTearDown(following.close);
    await tester.pumpWidget(
      _app(
        const StorePage(
          storeName: 'Real individual seller',
          sellerId: 'seller-1',
          sellerType: SellerType.individual,
        ),
        businessRepository: _TestBusinessRepository(),
        following: following,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Real individual seller'), findsOneWidget);
    expect(find.text('Bireysel satıcı'), findsOneWidget);
    expect(find.textContaining('0 '), findsOneWidget);
    expect(find.text('followers'), findsNothing);
    expect(find.text('views'), findsNothing);
    expect(find.text('+994 123456789'), findsNothing);
    expect(find.text('tiktok.com'), findsNothing);
    expect(find.text('WhatsApp'), findsNothing);
    expect(find.text('Kapalı'), findsNothing);
    expect(find.text('İstanbul'), findsNothing);
    expect(find.text('Elektronik'), findsNothing);
  });

  testWidgets('store profile renders provided fields and omits null fields', (
    tester,
  ) async {
    final following = FollowingCubit(MockEngagementRepository.instance);
    addTearDown(following.close);
    await tester.pumpWidget(
      _app(
        const StorePage(
          storeName: 'Seller full name',
          sellerId: 'store-1',
          sellerType: SellerType.store,
        ),
        businessRepository: _TestBusinessRepository(
          profile: const PublicStoreProfile(
            sellerId: 'store-1',
            fullName: 'Seller full name',
            storeName: 'Real store name',
            category: 'COSMETICS',
            description: 'Backend description',
            products: 4,
            views: 12,
            followers: 3,
            opensAt: '09:00',
            closesAt: '18:00',
          ),
        ),
        following: following,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Real store name'), findsOneWidget);
    expect(find.text('COSMETICS'), findsOneWidget);
    expect(find.text('Backend description'), findsOneWidget);
    expect(find.text('09:00 – 18:00'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('+994 123456789'), findsNothing);
    expect(find.text('tiktok.com'), findsNothing);
    expect(find.text('İstanbul'), findsNothing);
  });
}

Widget _app(
  Widget page, {
  required BusinessRepository businessRepository,
  required FollowingCubit following,
}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, child) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<HomeRepository>.value(value: _TestHomeRepository()),
      RepositoryProvider<BusinessRepository>.value(value: businessRepository),
    ],
    child: BlocProvider<FollowingCubit>.value(
      value: following,
      child: MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    ),
  ),
);

class _TestHomeRepository implements HomeRepository {
  @override
  Future<PageResponse<FeedItem>> fetchListings({
    int page = 1,
    int size = 5,
    String? categoryId,
    String? subcategoryId,
    String? cityId,
    String? sellerId,
    FeedTab tab = FeedTab.forYou,
    double? latitude,
    double? longitude,
    SellerType? sellerType,
    bool productsOnly = false,
  }) async => const PageResponse(
    items: [],
    page: 0,
    size: 50,
    totalElements: 0,
    totalPages: 0,
    last: true,
  );
}

class _TestBusinessRepository implements BusinessRepository {
  _TestBusinessRepository({this.profile});

  final PublicStoreProfile? profile;

  @override
  StoreDraft? get currentDraft => null;

  @override
  Future<PublicStoreProfile?> fetchPublicStore(String sellerId) async =>
      profile;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<MyStore?> fetchMyStore() async => null;

  @override
  Future<StoreStatistics> fetchMyStoreStatistics() =>
      throw UnimplementedError();
}

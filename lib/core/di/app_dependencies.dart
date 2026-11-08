import 'package:flutter/foundation.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/repositories/api_auth_repository.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/features/home/repositories/api_home_repository.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/features/home/repositories/api_listing_detail_repository.dart';
import 'package:vidsell/features/home/repositories/listing_detail_repository.dart';
import 'package:vidsell/features/home/repositories/mock_listing_detail_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_wallet_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_wallet_repository.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_settings_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_settings_repository.dart';
import 'package:vidsell/features/cabinet/repositories/settings_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_payment_provider.dart';
import 'package:vidsell/features/cabinet/repositories/mock_payment_provider.dart';
import 'package:vidsell/features/cabinet/repositories/payment_provider.dart';
import 'package:vidsell/features/cabinet/repositories/api_user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/features/discover/repositories/api_business_repository.dart';
import 'package:vidsell/features/discover/repositories/api_catalog_repository.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_city_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_subcategory_repository.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';
import 'package:vidsell/features/discover/repositories/api_engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/api_search_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_search_repository.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/features/new_listing/repositories/api_listing_repository.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/features/new_listing/repositories/mock_listing_repository.dart';
import 'package:vidsell/features/new_listing/repositories/api_promotion_repository.dart';
import 'package:vidsell/features/new_listing/repositories/mock_promotion_repository.dart';
import 'package:vidsell/features/new_listing/repositories/promotion_repository.dart';
import 'package:vidsell/features/messages/repositories/api_messaging_repository.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';
import 'package:vidsell/features/messages/repositories/mock_messaging_repository.dart';

class AppDependencies {
  AppDependencies({AppConfig? config})
    : config = config ?? AppConfig.fromEnvironment(),
      sessionStore = SecureSessionStore() {
    if (kReleaseMode && this.config.useMockBackend) {
      throw StateError('Mock backend mode is not allowed in release builds.');
    }

    apiClient = ApiClient(config: this.config, sessionStore: sessionStore);
    final mockUserListings = this.config.useMockBackend
        ? MockUserListingRepository()
        : null;

    // All repositories are initialized once here so that every caller in the
    // app — BlocProviders, RepositoryProviders, or any widget — receives the
    // same shared instance. Using getters would construct a new object on every
    // read, which breaks singleton mocks and shared state.
    authRepository = this.config.useMockBackend
        ? MockAuthRepository(sessionStore: sessionStore)
        : ApiAuthRepository(client: apiClient, sessionStore: sessionStore);

    homeRepository = this.config.useMockBackend
        ? MockHomeRepository(userListingRepository: mockUserListings)
        : ApiHomeRepository(apiClient);

    listingRepository = this.config.useMockBackend
        ? MockListingRepository(onListingCreated: mockUserListings!.addListing)
        : ApiListingRepository(apiClient);

    listingDetailRepository = this.config.useMockBackend
        ? MockListingDetailRepository(homeRepository: homeRepository)
        : ApiListingDetailRepository(apiClient);

    userListingRepository = this.config.useMockBackend
        ? mockUserListings!
        : ApiUserListingRepository(apiClient);

    statusCountRepository = this.config.useMockBackend
        ? MockStatusCountRepository()
        : ApiStatusCountRepository(apiClient);

    profileRepository = this.config.useMockBackend
        ? MockProfileRepository(sessionStore: sessionStore)
        : ApiProfileRepository(apiClient, sessionStore: sessionStore);

    walletRepository = this.config.useMockBackend
        ? MockWalletRepository.instance
        : ApiWalletRepository(apiClient);

    settingsRepository = this.config.useMockBackend
        ? MockSettingsRepository()
        : ApiSettingsRepository(apiClient);

    promotionRepository = this.config.useMockBackend
        ? MockPromotionRepository()
        : ApiPromotionRepository(apiClient);

    paymentProvider = this.config.useMockBackend
        ? MockPaymentProvider()
        : const ApiPaymentProvider();

    businessRepository = this.config.useMockBackend
        ? MockBusinessRepository.instance
        : ApiBusinessRepository(apiClient);

    cityRepository = this.config.useMockBackend
        ? MockCityRepository()
        : ApiCityRepository(apiClient);

    subcategoryRepository = this.config.useMockBackend
        ? MockSubcategoryRepository()
        : ApiSubcategoryRepository(apiClient);

    engagementRepository = this.config.useMockBackend
        ? MockEngagementRepository(sessionStore: sessionStore)
        : ApiEngagementRepository(apiClient);

    searchRepository = this.config.useMockBackend
        ? MockSearchRepository(homeRepository: homeRepository)
        : ApiSearchRepository(apiClient);

    messagingRepository = this.config.useMockBackend
        ? MockMessagingRepository.instance
        : ApiMessagingRepository(apiClient);
  }

  final AppConfig config;
  final SessionStore sessionStore;
  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final HomeRepository homeRepository;
  late final ListingRepository listingRepository;
  late final ListingDetailRepository listingDetailRepository;
  late final UserListingRepository userListingRepository;
  late final StatusCountRepository statusCountRepository;
  late final ProfileRepository profileRepository;
  late final WalletRepository walletRepository;
  late final SettingsRepository settingsRepository;
  late final PromotionRepository promotionRepository;
  late final PaymentProvider paymentProvider;
  late final BusinessRepository businessRepository;
  late final CityRepository cityRepository;
  late final SubcategoryRepository subcategoryRepository;
  late final EngagementRepository engagementRepository;
  late final SearchRepository searchRepository;
  late final MessagingRepository messagingRepository;
}

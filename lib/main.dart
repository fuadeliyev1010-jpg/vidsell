import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/state/app_navigation_cubit.dart';
import 'package:vidsell/core/state/app_locale_cubit.dart';
import 'package:vidsell/core/state/app_runtime_cubit.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_theme.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/di/app_dependencies.dart';
import 'package:vidsell/core/widgets/app_runtime_overlay.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/repositories/listing_detail_repository.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/features/cabinet/repositories/payment_provider.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/core/pager/app_router.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (_) => const _ApplicationErrorPage();
  runZonedGuarded(
    () => runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
    (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'vidsell',
          context: ErrorDescription('uncaught application error'),
        ),
      );
    },
  );
}

class _ApplicationErrorPage extends StatelessWidget {
  const _ApplicationErrorPage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.primaryColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.appError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        ScreenUtil.configure(data: MediaQuery.of(context));

        final dependencies = AppDependencies();
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  AuthBloc(repository: dependencies.authRepository)
                    ..add(const AuthStarted()),
            ),
            BlocProvider(create: (_) => AppNavigationCubit()),
            BlocProvider(create: (_) => AppLocaleCubit()),
            BlocProvider(create: (_) => AppRuntimeCubit()),
            BlocProvider(
              create: (_) => FavoritesCubit(dependencies.engagementRepository),
            ),
            BlocProvider(
              create: (_) => FollowingCubit(dependencies.engagementRepository),
            ),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.status != current.status ||
                previous.session?.user.id != current.session?.user.id,
            listener: (context, state) {
              final favorites = context.read<FavoritesCubit>();
              final following = context.read<FollowingCubit>();
              if (state.status == AuthStatus.authenticated) {
                favorites.reset();
                following.reset();
                unawaited(_loadEngagement(favorites, following));
              } else if (state.status == AuthStatus.unauthenticated) {
                favorites.reset();
                following.reset();
              }
            },
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AppConfig>.value(value: dependencies.config),
                RepositoryProvider<HomeRepository>.value(
                  value: dependencies.homeRepository,
                ),
                RepositoryProvider<ListingRepository>.value(
                  value: dependencies.listingRepository,
                ),
                RepositoryProvider<ListingDetailRepository>.value(
                  value: dependencies.listingDetailRepository,
                ),
                RepositoryProvider<UserListingRepository>.value(
                  value: dependencies.userListingRepository,
                ),
                RepositoryProvider<StatusCountRepository>.value(
                  value: dependencies.statusCountRepository,
                ),
                RepositoryProvider<ProfileRepository>.value(
                  value: dependencies.profileRepository,
                ),
                RepositoryProvider<WalletRepository>.value(
                  value: dependencies.walletRepository,
                ),
                RepositoryProvider<PaymentProvider>.value(
                  value: dependencies.paymentProvider,
                ),
                RepositoryProvider<BusinessRepository>.value(
                  value: dependencies.businessRepository,
                ),
                RepositoryProvider<CityRepository>.value(
                  value: dependencies.cityRepository,
                ),
                RepositoryProvider<SubcategoryRepository>.value(
                  value: dependencies.subcategoryRepository,
                ),
                RepositoryProvider<EngagementRepository>.value(
                  value: dependencies.engagementRepository,
                ),
                RepositoryProvider<SearchRepository>.value(
                  value: dependencies.searchRepository,
                ),
                RepositoryProvider<MessagingRepository>.value(
                  value: dependencies.messagingRepository,
                ),
              ],
              child: BlocBuilder<AppLocaleCubit, Locale>(
                builder: (context, locale) {
                  dependencies.apiClient.setLanguage(locale.languageCode);
                  return MaterialApp.router(
                    routerConfig: appRouter,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.darkTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: ThemeMode.dark,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    builder: (context, child) => AppRuntimeOverlay(
                      child: DevicePreview.appBuilder(context, child),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadEngagement(
    FavoritesCubit favorites,
    FollowingCubit following,
  ) async {
    try {
      await Future.wait([favorites.load(), following.load()]);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'engagement state',
          context: ErrorDescription(
            'while loading the signed-in user favorites and followed stores',
          ),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/call_seller.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_icon_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/core/widgets/transparent_text_button.dart';
import 'package:vidsell/features/home/page/store_page.dart';
import 'package:vidsell/features/home/widgets/product_details_sheet.dart';
import 'package:vidsell/features/home/widgets/home_listing_media.dart';
import 'package:vidsell/features/home/widgets/share_bottom_sheet.dart';
import 'package:vidsell/features/home/widgets/home_badge.dart';
import 'package:vidsell/features/home/widgets/home_circle_action.dart';
import 'package:vidsell/features/messages/utils/open_seller_chat.dart';
import 'package:vidsell/features/home/bloc/home_bloc.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/page/report_listing_page.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/pages/city_picker_page.dart';
import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/pages/search_page.dart';
import 'package:vidsell/core/services/location_permission_service.dart';
import 'package:latlong2/latlong.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository, this.listing});

  final HomeRepository? repository;
  final HomeListing? listing;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _HomeFeedTab { forYou, nearby, following }

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  final PageController _pageController = PageController();
  int _currentListingIndex = 0;
  int _playbackSession = 0;
  final bool _detailsExpanded = false;
  bool _isPlaying = true; // video/gif starts playing by default
  bool _isMuted = false;
  bool _isFeedMenuExpanded = false;
  bool _feedResetPending = false;
  bool _hasSelectedFeed = false;
  _HomeFeedTab _selectedFeedTab = _HomeFeedTab.forYou;
  HomeFeedQuery _currentFeedQuery = const HomeFeedQuery();

  Future<void> _setFavorite(HomeListing listing) async {
    final nextValue = !context.read<FavoritesCubit>().isFavorite(listing.id);
    if (widget.listing == null) {
      _homeBloc.add(
        HomeListingFavoriteChanged(
          listingId: listing.id,
          isFavorite: nextValue,
        ),
      );
    }
    try {
      await context.read<FavoritesCubit>().toggle(
        listingId: listing.id,
        enabled: nextValue,
        item: EngagementItem(
          id: listing.id,
          title: listing.title,
          imageUrl: listing.imagePath,
          subtitle: listing.price,
          videoUrl: listing.videoUrl,
          categoryId: listing.categoryId,
        ),
      );
    } catch (_) {
      if (mounted && widget.listing == null) {
        _homeBloc.add(
          HomeListingFavoriteChanged(
            listingId: listing.id,
            isFavorite: !nextValue,
          ),
        );
      }
    }
  }

  Widget _buildBackButton() {
    return Material(
      color: AppColor.primaryColor.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: context.goBack,
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 23.sp,
          ),
        ),
      ),
    );
  }

  Future<void> _setFollowing(HomeListing listing) async {
    final sellerId = listing.sellerId;
    if (sellerId == null || sellerId.isEmpty) return;
    final following = context.read<FollowingCubit>();
    final nextValue = !following.isFollowing(sellerId);
    try {
      await following.toggle(
        storeId: sellerId,
        enabled: nextValue,
        item: EngagementItem(
          id: sellerId,
          title: listing.sellerName,
          imageUrl: null,
          subtitle: listing.sellerHandle,
        ),
      );
    } catch (_) {
      // FollowingCubit restores the previous state when the request fails.
    }
  }

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(
      repository: widget.repository ?? context.read<HomeRepository>(),
    );
    if (widget.listing == null) {
      _homeBloc.add(const HomeListingsRequested());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final listing = widget.listing;
            if (listing != null) {
              return _buildListingPage(listing, 0);
            }

            if (state.status == HomeStatus.loading ||
                state.status == HomeStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state.status == HomeStatus.failure) {
              return _buildErrorState(context);
            }

            if (state.listings.isEmpty) {
              return _buildEmptyState(context);
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const _SinglePageScrollPhysics(),
              itemCount: state.listings.length,
              onPageChanged: (index) {
                final shouldPlay = _isPlaying && !_feedResetPending;
                final keepFeedChoicesVisible =
                    !_isPlaying && _isFeedMenuExpanded;
                _feedResetPending = false;
                setState(() {
                  _currentListingIndex = index;
                  _playbackSession++;
                  _isPlaying = shouldPlay;
                  _isFeedMenuExpanded = shouldPlay
                      ? false
                      : keepFeedChoicesVisible;
                });
                if (index >= state.listings.length - 2 &&
                    state.nextCursor != null) {
                  context.read<HomeBloc>().add(
                    const HomeMoreListingsRequested(),
                  );
                }
              },
              itemBuilder: (context, index) =>
                  _buildListingPage(state.listings[index], index),
            );
          },
        ),
        bottomNavigationBar: widget.listing == null
            ? const BottomNavigation(currentNavIndex: 0)
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: Colors.white, size: 42),
            12.height,
            Text(
              context.l10n.homeEmpty,
              style: AppTextStyle.primaryText.copyWith(color: Colors.white),
            ),
            16.height,
            TextButton(
              onPressed: () => context.read<HomeBloc>().add(
                HomeListingsRequested(refresh: true, query: _currentFeedQuery),
              ),
              child: Text(context.l10n.retryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 42),
            12.height,
            Text(
              context.l10n.homeLoadError,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(color: Colors.white),
            ),
            16.height,
            TextButton(
              onPressed: () => context.read<HomeBloc>().add(
                HomeListingsRequested(query: _currentFeedQuery),
              ),
              child: Text(context.l10n.retryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingPage(HomeListing listing, int index) {
    return TickerMode(
      enabled: index == _currentListingIndex && _isPlaying,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HomeListingMedia(
            listing: listing,
            playing: _isPlaying && index == _currentListingIndex,
            muted: _isMuted,
            playbackSession: _playbackSession,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 260.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _isPlaying = !_isPlaying;
                _isFeedMenuExpanded = !_isPlaying;
              }),
            ),
          ),
          if (!_isPlaying)
            Center(
              child: IgnorePointer(
                child: Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 44.sp,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(listing),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _buildBottomContent(listing)),
                    _buildRightActions(listing),
                  ],
                ),
                8.height,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(HomeListing listing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: widget.listing == null
          ? _hasSelectedFeed
                ? _buildHomeFeedTopBar(listing)
                : _buildDefaultHomeTopBar(listing)
          : _isPlaying
          ? Row(
              children: [
                if (widget.listing != null) ...[_buildBackButton(), 8.width],
                HomeBadge(
                  label: context.l10n.vip,
                  imagePath: 'assets/icons/solar_crown-line-bold.svg',
                  color: const Color(0xFF7C3AED),
                ),
                8.width,
                HomeBadge(
                  label: context.l10n.premium,
                  icon: Icons.star,
                  color: const Color(0xFFD4A017),
                ),
                8.width,
                const HomeBadge(
                  imagePath: 'assets/icons/material-symbols_store.svg',
                  color: Color(0xFF38BDF8),
                ),
                const Spacer(),

                AppIconButton(
                  width: 40.w,
                  height: 40.h,
                  iconPath: 'assets/icons/search.svg',
                  radius: 100.r,
                  backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
                  onPressed: _openSearchPage,
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    if (widget.listing != null) ...[_buildBackButton()],
                    const Spacer(),
                    AppIconButton(
                      width: 40.w,
                      height: 40.h,
                      icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                      radius: 100.r,
                      backgroundColor: AppColor.primaryColor.withValues(
                        alpha: 0.4,
                      ),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                    8.width,
                    AppIconButton(
                      width: 40.w,
                      height: 40.h,
                      iconPath: 'assets/icons/Vector2.svg',
                      radius: 100.r,
                      backgroundColor: AppColor.primaryColor.withValues(
                        alpha: 0.4,
                      ),
                      onPressed: () {
                        showShareBottomSheet(
                          context,
                          sellerName: listing.sellerName,
                          link: listing.shareLink,
                        );
                      },
                    ),
                    8.width,
                    AppIconButton(
                      width: 40.w,
                      height: 40.h,
                      iconPath: 'assets/icons/search.svg',
                      radius: 100.r,
                      backgroundColor: AppColor.primaryColor.withValues(
                        alpha: 0.4,
                      ),
                      onPressed: _openSearchPage,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDefaultHomeTopBar(HomeListing listing) {
    if (_isPlaying) {
      return Row(
        children: [
          HomeBadge(
            label: context.l10n.vip,
            imagePath: 'assets/icons/solar_crown-line-bold.svg',
            color: const Color(0xFF7C3AED),
          ),
          8.width,
          HomeBadge(
            label: context.l10n.premium,
            icon: Icons.star,
            color: const Color(0xFFD4A017),
          ),
          8.width,
          const HomeBadge(
            imagePath: 'assets/icons/material-symbols_store.svg',
            color: Color(0xFF38BDF8),
          ),
          const Spacer(),
          AppIconButton(
            width: 40.w,
            height: 40.h,
            iconPath: 'assets/icons/search.svg',
            radius: 100.r,
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
            onPressed: _openSearchPage,
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildPlaybackActions(listing),
        20.height,
        _buildFeedChoices(),
      ],
    );
  }

  Widget _buildHomeFeedTopBar(HomeListing listing) {
    return Column(
      children: [
        Row(
          children: [
            _buildFeedBackButton(),
            8.width,
            TransparentTextButton(
              text: _feedTabLabel(context),
              isSelected: true,
              onPressed: _isPlaying
                  ? () {}
                  : () => setState(
                      () => _isFeedMenuExpanded = !_isFeedMenuExpanded,
                    ),
            ),
            const Spacer(),
            if (!_isPlaying) ...[..._playbackActionWidgets(listing)],
          ],
        ),
        if (!_isPlaying && _isFeedMenuExpanded) ...[
          20.height,
          _buildFeedChoices(),
        ],
      ],
    );
  }

  Widget _buildPlaybackActions(HomeListing listing) =>
      Row(children: [const Spacer(), ..._playbackActionWidgets(listing)]);

  List<Widget> _playbackActionWidgets(HomeListing listing) => [
    AppIconButton(
      width: 40.w,
      height: 40.h,
      icon: _isMuted ? Icons.volume_off : Icons.volume_up,
      radius: 100.r,
      backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
      onPressed: () => setState(() => _isMuted = !_isMuted),
    ),
    8.width,
    AppIconButton(
      width: 40.w,
      height: 40.h,
      iconPath: 'assets/icons/Vector2.svg',
      radius: 100.r,
      backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
      onPressed: () {
        showShareBottomSheet(
          context,
          sellerName: listing.sellerName,
          link: listing.shareLink,
        );
      },
    ),
    8.width,
    AppIconButton(
      width: 40.w,
      height: 40.h,
      iconPath: 'assets/icons/search.svg',
      radius: 100.r,
      backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
      onPressed: _openSearchPage,
    ),
  ];

  Widget _buildFeedChoices() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 14.w,
    children: [
      TransparentTextButton(
        text: context.l10n.homeForYou,
        isSelected: _hasSelectedFeed && _selectedFeedTab == _HomeFeedTab.forYou,
        onPressed: () => _selectFeed(_HomeFeedTab.forYou),
      ),
      TransparentTextButton(
        text: context.l10n.nearby,
        isSelected: _hasSelectedFeed && _selectedFeedTab == _HomeFeedTab.nearby,
        onPressed: () => _selectFeed(_HomeFeedTab.nearby),
      ),
      TransparentTextButton(
        text: context.l10n.followingTab,
        isSelected:
            _hasSelectedFeed && _selectedFeedTab == _HomeFeedTab.following,
        onPressed: () => _selectFeed(_HomeFeedTab.following),
      ),
    ],
  );

  String _feedTabLabel(BuildContext context) => switch (_selectedFeedTab) {
    _HomeFeedTab.forYou => context.l10n.homeForYou,
    _HomeFeedTab.nearby => context.l10n.nearby,
    _HomeFeedTab.following => context.l10n.followingTab,
  };

  Widget _buildFeedBackButton() {
    return Material(
      color: AppColor.primaryColor.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _exitSelectedFeed,
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 23.sp,
          ),
        ),
      ),
    );
  }

  void _exitSelectedFeed() {
    final oldPage = _pageController.hasClients
        ? _pageController.page?.round() ?? 0
        : 0;
    _feedResetPending = oldPage != 0;
    setState(() {
      _hasSelectedFeed = false;
      _selectedFeedTab = _HomeFeedTab.forYou;
      _currentFeedQuery = const HomeFeedQuery();
      _currentListingIndex = 0;
      _playbackSession++;
      _isFeedMenuExpanded = !_isPlaying;
    });
    if (_pageController.hasClients && oldPage != 0) {
      _pageController.jumpToPage(0);
    }
    _homeBloc.add(
      const HomeListingsRequested(refresh: true, query: HomeFeedQuery()),
    );
  }

  Future<void> _selectFeed(_HomeFeedTab tab) async {
    if (tab == _selectedFeedTab) {
      if (tab == _HomeFeedTab.forYou) {
        await _selectForYouFeed();
      } else {
        setState(() => _isFeedMenuExpanded = false);
      }
      return;
    }

    switch (tab) {
      case _HomeFeedTab.forYou:
        await _selectForYouFeed();
      case _HomeFeedTab.following:
        try {
          _activateFeed(tab, const HomeFeedQuery(tab: FeedTab.following));
        } catch (error) {
          _showFeedError(error);
        }
      case _HomeFeedTab.nearby:
        await _selectNearbyFeed();
    }
  }

  Future<void> _selectForYouFeed() async {
    try {
      final favorites = context.read<FavoritesCubit>();
      await favorites.load();
      if (!mounted) return;
      final favoriteIds = favorites.state.keys.toSet();
      final likedCategories = <String>{
        for (final item in favorites.state.values)
          if (item.categoryId != null && item.categoryId!.isNotEmpty)
            item.categoryId!,
        for (final listing in _homeBloc.state.listings)
          if (favoriteIds.contains(listing.id) &&
              listing.categoryId != null &&
              listing.categoryId!.isNotEmpty)
            listing.categoryId!,
      };
      _activateFeed(
        _HomeFeedTab.forYou,
        likedCategories.isEmpty
            ? const HomeFeedQuery()
            : HomeFeedQuery(categoryIds: likedCategories.toList()),
      );
    } catch (error) {
      _showFeedError(error);
    }
  }

  Future<void> _selectNearbyFeed() async {
    LatLng? location;
    Object? locationError;
    try {
      location = await LocationPermissionService().getCurrentLocation();
    } catch (error) {
      locationError = error;
    }
    if (!mounted) return;
    if (location != null) {
      _activateFeed(
        _HomeFeedTab.nearby,
        HomeFeedQuery(
          tab: FeedTab.nearby,
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
      return;
    }

    if (locationError != null) _showFeedError(locationError);
    final city = await context.goTo<City>(const CityPickerPage());
    if (!mounted || city == null) return;
    _activateFeed(
      _HomeFeedTab.nearby,
      HomeFeedQuery(tab: FeedTab.nearby, cityId: city.id),
    );
  }

  void _activateFeed(_HomeFeedTab tab, HomeFeedQuery query) {
    final oldPage = _pageController.hasClients
        ? _pageController.page?.round() ?? 0
        : 0;
    _feedResetPending = oldPage != 0;
    setState(() {
      _hasSelectedFeed = true;
      _selectedFeedTab = tab;
      _currentFeedQuery = query;
      _currentListingIndex = 0;
      _playbackSession++;
      _isPlaying = false;
      _isFeedMenuExpanded = false;
    });
    if (_pageController.hasClients && oldPage != 0) {
      _pageController.jumpToPage(0);
    }
    _homeBloc.add(HomeListingsRequested(refresh: true, query: query));
  }

  void _showFeedError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Widget _buildRightActions(HomeListing listing) {
    final isFavorite = context.watch<FavoritesCubit>().isFavorite(listing.id);
    return Column(
      children: [
        HomeCircleAction(
          iconPath: isFavorite
              ? 'assets/icons/red_like_icon.dart.svg'
              : 'assets/icons/like_icon.svg',
          onTap: () => _setFavorite(listing),
        ),
        18.height,
        HomeCircleAction(
          iconPath: 'assets/icons/phone_icon.svg',
          onTap: () {
            callSeller(context, listing.phoneNumber);
          },
        ),
        18.height,
        HomeCircleAction(
          iconPath: 'assets/icons/icon3.svg',
          onTap: () => _openSellerChat(listing),
        ),
      ],
    );
  }

  void _openSearchPage() {
    context.goTo(const SearchPage());
  }

  Future<void> _openStorePage(HomeListing listing) {
    return _navigateWithPlaybackPaused(
      () => context.goTo<void>(
        StorePage(
          storeName: listing.sellerName,
          sellerId: listing.sellerId,
          sellerAvatar: listing.sellerAvatar,
          category: context.l10n.categoryElectronics,
        ),
      ),
    );
  }

  Future<void> _openSellerChat(HomeListing listing, {String? initialMessage}) {
    return _navigateWithPlaybackPaused(
      () => openSellerChat(context, listing, initialMessage: initialMessage),
    );
  }

  Future<void> _navigateWithPlaybackPaused(
    Future<void> Function() navigate,
  ) async {
    final wasPlaying = _isPlaying;
    if (wasPlaying) setState(() => _isPlaying = false);
    try {
      await navigate();
    } finally {
      if (mounted && wasPlaying) setState(() => _isPlaying = true);
    }
  }

  Future<void> _openProductDetails(HomeListing listing) async {
    final wasPlaying = _isPlaying;
    setState(() => _isPlaying = false);
    await showProductDetailsSheet(
      context,
      listing: ProductLegacyAdapter.fromHomeListing(listing),
      onMessage: (message) {
        Navigator.of(context).pop();
        _openSellerChat(
          listing,
          initialMessage: message.isEmpty ? null : message,
        );
      },
      onReport: () {
        context.goTo(ReportListingPage(listingId: listing.id));
      },
      onBlock: listing.sellerId == null
          ? null
          : () async {
              await context.read<EngagementRepository>().blockUser(
                listing.sellerId!,
              );
              if (mounted) Navigator.of(context).pop();
            },
    );
    if (!mounted ||
        !wasPlaying ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    setState(() => _isPlaying = true);
  }

  Widget _buildBottomContent(HomeListing listing) {
    final isFollowing =
        listing.sellerId != null &&
        context.watch<FollowingCubit>().isFollowing(listing.sellerId!);
    return Padding(
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        bottom: 14.h,
        top: 14.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller row.
          Row(
            children: [
              // Tapping the avatar/name opens the store's page.
              Flexible(
                child: GestureDetector(
                  onTap: () => _openStorePage(listing),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      widget.listing != null
                          ? _buildSellerAvatar(listing)
                          : CircleAvatar(
                              radius: 16.r,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                            ),
                      8.width,
                      Expanded(
                        child: Text(
                          widget.listing != null
                              ? (listing.sellerName.isNotEmpty
                                    ? listing.sellerName
                                    : listing.sellerHandle)
                              : listing.sellerHandle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              10.width,
              GestureDetector(
                onTap: () => _setFollowing(listing),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.h,
                    vertical: 5.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    isFollowing
                        ? context.l10n.followingStatus
                        : context.l10n.follow,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          10.height,

          // Price.
          Text(
            listing.price,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.activeColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          6.height,

          // Product title.
          Text(
            listing.title,
            maxLines: _detailsExpanded ? null : 2,
            overflow: _detailsExpanded ? null : TextOverflow.ellipsis,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),

          10.height,

          // Product details expandable chip.
          TransparentTextButton(
            text: context.l10n.productDetails,
            onPressed: () => _openProductDetails(listing),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSellerAvatar(HomeListing listing) {
    final avatar = listing.sellerAvatar?.trim();
    final avatarUri = avatar == null ? null : Uri.tryParse(avatar);
    final isNetworkAvatar =
        avatarUri != null &&
        (avatarUri.scheme == 'http' || avatarUri.scheme == 'https');

    return CircleAvatar(
      radius: 16.r,
      backgroundColor: Colors.white24,
      backgroundImage: isNetworkAvatar ? NetworkImage(avatar!) : null,
      child: isNetworkAvatar
          ? null
          : Icon(Icons.person, color: Colors.white, size: 32.sp),
    );
  }
}

class _SinglePageScrollPhysics extends PageScrollPhysics {
  const _SinglePageScrollPhysics({super.parent});

  @override
  _SinglePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SinglePageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    final page = position.pixels / position.viewportDimension;
    final targetPage = velocity > tolerance.velocity
        ? page.floor() + 1
        : velocity < -tolerance.velocity
        ? page.ceil() - 1
        : page.round();
    final clampedPage = targetPage.clamp(
      (position.minScrollExtent / position.viewportDimension).round(),
      (position.maxScrollExtent / position.viewportDimension).round(),
    );
    final target = clampedPage * position.viewportDimension;

    if (target == position.pixels) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

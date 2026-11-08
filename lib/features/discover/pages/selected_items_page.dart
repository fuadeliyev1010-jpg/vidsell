import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/pages/category_grid_page.dart';
import 'package:vidsell/features/discover/pages/search_page.dart';
import 'package:vidsell/features/discover/pages/stores_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/models/saved_search.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/models/product/product.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SelectedItemsPage extends StatefulWidget {
  const SelectedItemsPage({super.key});

  @override
  State<SelectedItemsPage> createState() => _SelectedItemsPageState();
}

class _SelectedItemsPageState extends State<SelectedItemsPage> {
  int _selectedTabIndex = 0;
  int _visibleFavoriteCount = 8;
  late final EngagementRepository _repository;
  late Future<Object> _itemsFuture;
  StreamSubscription<Map<String, EngagementItem>>? _favoritesSubscription;
  StreamSubscription<Map<String, EngagementItem>>? _followingSubscription;
  AuthBloc? _authBloc;
  StreamSubscription<AuthState>? _authSubscription;

  List<String> _tabs(BuildContext context) => [
    context.l10n.savedListingsTab,
    context.l10n.savedSearchesTab,
    context.l10n.followedStoresTab,
  ];

  @override
  void initState() {
    super.initState();
    _repository = context.read<EngagementRepository>();
    _favoritesSubscription = context.read<FavoritesCubit>().stream.listen(
      _handleFavoritesChanged,
    );
    _followingSubscription = context.read<FollowingCubit>().stream.listen(
      _handleFollowingChanged,
    );
    _authBloc = context.read<AuthBloc?>();
    // Always attempt to load items — _loadFavorites handles the not-yet-loaded
    // case gracefully. Using Future.value([]) when status is unknown caused the
    // page to stay blank if auth was already resolved before the stream fired.
    _itemsFuture = _loadItems();
    _authSubscription = _authBloc?.stream.listen(_handleAuthState);
    // If the cubit already has data (loaded before the page opened), the
    // stream won't emit again. Trigger a reload after the first frame so
    // _handleFavoritesChanged has a chance to pick up the current state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<FavoritesCubit>();
      if (cubit.isLoaded && cubit.state.isNotEmpty && _selectedTabIndex == 0) {
        setState(() {
          _itemsFuture = Future<Object>.value(
            cubit.state.values.toList(growable: false).reversed.toList(),
          );
        });
      }
    });
  }

  void _handleFavoritesChanged(Map<String, EngagementItem> favorites) {
    if (!mounted) return;
    // Always update when on the favorites tab so the initial load resolves.
    if (_selectedTabIndex != 0) return;
    setState(() {
      _itemsFuture = Future<Object>.value(
        favorites.values.toList(growable: false).reversed.toList(),
      );
    });
  }

  void _handleFollowingChanged(Map<String, EngagementItem> stores) {
    if (!mounted) return;
    if (_selectedTabIndex != 2) return;
    setState(() {
      _itemsFuture = Future<Object>.value(
        stores.values.toList(growable: false).reversed.toList(),
      );
    });
  }

  void _handleAuthState(AuthState state) {
    if (!mounted) return;
    setState(() {
      _itemsFuture = state.status == AuthStatus.authenticated
          ? _loadItems()
          : Future<Object>.value(const <Object>[]);
    });
  }

  Future<Object> _loadItems() {
    if (_selectedTabIndex == 0) {
      return _loadFavorites();
    }
    if (_selectedTabIndex == 1) return _repository.fetchSavedSearches();
    return _loadFollowedStores();
  }

  Future<Object> _loadFavorites() async {
    final cubit = context.read<FavoritesCubit>();
    if (!cubit.isLoaded && cubit.state.isEmpty) await cubit.load();
    return cubit.state.values.toList(growable: false).reversed.toList();
  }

  Future<Object> _loadFollowedStores() async {
    final cubit = context.read<FollowingCubit>();
    // Always await load if not yet loaded, regardless of current state contents.
    if (!cubit.isLoaded) await cubit.load();
    return cubit.state.values.toList(growable: false).reversed.toList();
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _visibleFavoriteCount = 8;
      _itemsFuture = _loadItems();
    });
  }

  void _refreshItems() {
    if (!mounted) return;
    setState(() {
      _itemsFuture = _loadItems();
    });
  }

  Future<void> _removeFollowedStore(EngagementItem item) async {
    try {
      await context.read<FollowingCubit>().toggle(
        storeId: item.id,
        enabled: false,
      );
      _refreshItems();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _clearCurrentTab() async {
    try {
      if (_selectedTabIndex == 0) {
        await context.read<FavoritesCubit>().clear();
      } else if (_selectedTabIndex == 1) {
        await _repository.clearSavedSearches();
      } else {
        await context.read<FollowingCubit>().clear();
      }
      _refreshItems();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _openCategories() {
    context.goTo(
      CategoryGridPage(categories: CategoryItem.categories.skip(1).toList()),
    );
  }

  void _openSearch() {
    context.goTo(const SearchPage());
  }

  void _openStores() {
    context.goTo(const StoresPage());
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_favoritesSubscription?.cancel());
    unawaited(_followingSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        toolbarHeight: 88.h,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.primaryColor,
        title: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    context.l10n.followingListTitle,
                    style: AppTextStyle.primaryText.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _clearCurrentTab,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Text(
                        context.l10n.clear,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.activeColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            14.height,
            const Divider(height: 1, color: AppColor.bgElavated),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTabs(),
                  16.height,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: FutureBuilder<Object>(
                        future: _itemsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: TextButton(
                                onPressed: _refreshItems,
                                child: Text(snapshot.error.toString()),
                              ),
                            );
                          }
                          final items = snapshot.data;
                          if (items is List && items.isNotEmpty) {
                            return _buildItems(items);
                          }
                          return _selectedTabIndex == 1
                              ? _buildSearchEmptyState()
                              : _selectedTabIndex == 2
                              ? _buildStoresEmptyState()
                              : _buildEmptyState();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BottomNavigation(currentNavIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 36.h,
      child: Row(
        children: List.generate(_tabs(context).length, (index) {
          final isSelected = index == _selectedTabIndex;
          return Expanded(
            child: InkWell(
              onTap: () => _selectTab(index),
              child: Column(
                children: [
                  Text(
                    _tabs(context)[index],
                    style: AppTextStyle.primaryText.copyWith(
                      color: isSelected
                          ? AppColor.activeColor
                          : AppColor.mutedColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 1.h,
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    color: isSelected
                        ? AppColor.activeColor
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItems(List<Object?> items) {
    if (_selectedTabIndex == 0) {
      final visibleItems = items.take(_visibleFavoriteCount).toList();
      final hasMore = visibleItems.length < items.length;
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              final item = visibleItems[index] as EngagementItem;
              return ProductCard(
                product: Product(
                  id: item.id,
                  imageUrls: [
                    if (item.imageUrl?.isNotEmpty == true) item.imageUrl!,
                  ],
                  price:
                      double.tryParse(
                        item.subtitle.replaceAll(RegExp(r'[^0-9.]'), ''),
                      ) ??
                      0,
                  currency: item.subtitle
                      .replaceAll(RegExp(r'[\d.,\s]'), '')
                      .trim(),
                  title: item.title,
                  isFavorite: true,
                ),
                videoUrl: item.videoUrl,
                onFavoriteToggle: _refreshItems,
              );
            },
          ),
          if (hasMore) ...[
            16.height,
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleFavoriteCount += 8;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.activeColor,
                  side: const BorderSide(color: AppColor.activeColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(context.l10n.showMore),
              ),
            ),
            16.height,
          ],
        ],
      );
    }

    return Column(
      children: items.map((item) {
        final title = item is EngagementItem
            ? item.title
            : (item as SavedSearch).query;
        final subtitle = item is EngagementItem
            ? item.subtitle
            : context.l10n.savedSearch;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () async {
              try {
                if (item is SavedSearch) {
                  await _repository.deleteSavedSearch(item.id);
                } else {
                  await _removeFollowedStore(item as EngagementItem);
                  return;
                }
                _refreshItems();
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.toString())));
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return _buildEmptyCard(
      title: context.l10n.noSavedListings,
      description: context.l10n.savedListingsEmptyDescription,
      buttonLabel: context.l10n.chooseCategory,
      icon: Icons.grid_view_rounded,
      onPressed: _openCategories,
    );
  }

  Widget _buildSearchEmptyState() {
    return _buildEmptyCard(
      title: context.l10n.noSavedSearches,
      description: context.l10n.savedSearchesEmptyDescription,
      buttonLabel: context.l10n.startSearching,
      icon: Icons.search,
      onPressed: _openSearch,
    );
  }

  Widget _buildStoresEmptyState() {
    return _buildEmptyCard(
      title: context.l10n.noFollowedStores,
      description: context.l10n.followedStoresEmptyDescription,
      buttonLabel: context.l10n.allStores,
      icon: Icons.format_list_bulleted,
      onPressed: _openStores,
    );
  }

  Widget _buildEmptyCard({
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 14.h, 13.w, 14.h),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.primaryText.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          9.height,
          Text(
            description,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.secondaryTextColor,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
          12.height,
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18.sp),
              label: Text(
                buttonLabel,
                style: AppTextStyle.primaryText.copyWith(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.bgElavated,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

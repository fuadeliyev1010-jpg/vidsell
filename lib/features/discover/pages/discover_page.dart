import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/features/discover/pages/category_grid_page.dart';
import 'package:vidsell/features/cabinet/pages/business_login_page.dart';
import 'package:vidsell/features/discover/pages/filter_page.dart';
import 'package:vidsell/features/discover/pages/search_page.dart';
import 'package:vidsell/features/discover/pages/selected_items_page.dart';
import 'package:vidsell/features/discover/models/listing_filter.dart';
import 'package:vidsell/features/discover/pages/category_results_page.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/discover/utils/video_slot_pool.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  int _selectedCategory = 0;

  static const int _bannerCount = 5;

  late final AnimationController _drawerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<Offset> _drawerOffset =
      Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
      );

  bool _isDrawerOpen = false;

  late final HomeRepository _homeRepository;
  final Map<int, Object> _videoRowGroups = {};
  List<Product> _listings = const [];
  bool _isLoadingListings = true;
  String? _listingsError;

  @override
  void initState() {
    super.initState();
    _homeRepository = context.read<HomeRepository>();
    _loadListings();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });
    try {
      final page = await _homeRepository.fetchListings(size: 50);
      if (!mounted) return;
      setState(() {
        _listings = page.items
            .map((item) => item.product)
            .whereType<Product>()
            .toList(growable: false);
        _isLoadingListings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listingsError = context.l10n.homeLoadError;
        _isLoadingListings = false;
      });
    }
  }

  void _openDrawerMenu() {
    setState(() => _isDrawerOpen = true);
    _drawerController.forward();
  }

  Future<void> _closeDrawerMenu() async {
    await _drawerController.reverse();
    if (!mounted) return;
    setState(() => _isDrawerOpen = false);
  }

  Future<void> _openSelectedItemsPage() async {
    await _closeDrawerMenu();
    if (!mounted) return;
    context.goTo(const SelectedItemsPage());
  }

  Future<void> _openBusinessLoginPage() async {
    await _closeDrawerMenu();
    if (!mounted) return;
    context.goTo(const BusinessLoginPage());
  }

  Widget _buildDrawerLayer() {
    if (!_isDrawerOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _drawerController,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeDrawerMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: SlideTransition(
            position: _drawerOffset,
            child: _buildDrawerPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerPanel() {
    // Design width ≈ 68% of the screen, capped so it doesn't stretch on wide screens.
    final width = (0.68 * MediaQuery.sizeOf(context).width).clamp(240.0, 320.0);

    return Material(
      color: Colors.transparent,
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
          child: Container(
            width: width,
            color: const Color(0xFF171C24),
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFF2B3342),
                      child: Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 22.sp,
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasan Memmedov',
                            style: AppTextStyle.primaryText.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          2.height,
                          Text(
                            'id: 270795',
                            style: AppTextStyle.primaryText.copyWith(
                              color: Colors.white38,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                24.height,
                _buildDrawerButton(
                  iconPath: 'assets/icons/tabler_plus-filled.svg',
                  title: context.l10n.newListing,
                  onTap: _closeDrawerMenu,
                ),
                _buildDrawerDivider(),
                _buildDrawerButton(
                  iconPath: 'assets/icons/like_icon.svg',
                  title: context.l10n.favorites,
                  onTap: _openSelectedItemsPage,
                ),
                _buildDrawerDivider(),
                _buildDrawerButton(
                  iconPath: 'assets/icons/6.svg',
                  title: context.l10n.support,
                  onTap: _closeDrawerMenu,
                ),
                _buildDrawerDivider(),
                _buildDrawerButton(
                  iconPath: 'assets/icons/8.svg',
                  title: context.l10n.aboutApp,
                  onTap: _closeDrawerMenu,
                ),
                _buildDrawerDivider(),
                _buildDrawerButton(
                  iconPath: 'assets/icons/mynaui_globe.svg',
                  title: context.l10n.englishMenu,
                  onTap: _closeDrawerMenu,
                ),
                _buildDrawerDivider(),
                _buildDrawerButton(
                  iconPath: 'assets/icons/4.svg',
                  title: context.l10n.contactUs,
                  onTap: _closeDrawerMenu,
                ),
                if (context.read<AppConfig>().useMockBackend) ...[
                  _buildDrawerDivider(),
                  _buildDrawerButton(
                    iconPath: 'assets/icons/akar-icons_briefcase.svg',
                    title: context.l10n.businesses,
                    onTap: _openBusinessLoginPage,
                    color: AppColor.activeColor,
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _buildDrawerButton({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20.sp,
              height: 20.sp,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            12.width,
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.primaryText.copyWith(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearchPage() {
    context.goTo(const SearchPage());
  }

  Future<void> _openFilterPage() async {
    final result = await context.goTo<ListingFilter>(const FilterPage());
    if (result != null && mounted) {
      context.goTo(
        CategoryResultsPage(
          filter: result,
          title: result.subcategoryName ?? result.categoryName ?? 'Telefonlar',
          categoryId: result.categoryId,
          subcategoryId: result.subcategoryId,
        ),
      );
    }
  }

  Future<void> _onCategoryTap(int index) async {
    if (index == 0) {
      final selected = await context.goTo<CategoryItem>(
        CategoryGridPage(categories: CategoryItem.categories.skip(1).toList()),
      );

      if (selected == null) return;

      final matchedIndex = CategoryItem.categories.indexOf(selected);
      if (matchedIndex != -1) {
        setState(() => _selectedCategory = matchedIndex);
      }
      return;
    }

    setState(() => _selectedCategory = index);
    final category = CategoryItem.categories[index];
    context.goTo(
      CategoryResultsPage(
        title: category.localizedLabel(context.l10n),
        categoryId: category.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDrawerOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isDrawerOpen) _closeDrawerMenu();
      },
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification ||
                            notification is ScrollStartNotification ||
                            notification is ScrollEndNotification) {
                          VideoSlotPool.instance.refresh();
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                12.height,
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        onTap: _openDrawerMenu,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(4.w),
                                          child: SvgPicture.asset(
                                            "assets/icons/tabler_menu-3.svg",
                                          ),
                                        ),
                                      ),
                                    ),
                                    _buildLogo(),
                                  ],
                                ),
                                16.height,
                                _buildSearchBar(),
                                16.height,
                                _buildBanner(),
                                16.height,
                                _buildCategoryRow(),
                                24.height,
                                _buildSectionHeader(),
                                16.height,
                              ]),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            sliver: _buildListingsGrid(),
                          ),
                          SliverToBoxAdapter(child: 24.height),
                        ],
                      ),
                    ),
                    _buildDrawerLayer(),
                  ],
                ),
              ),
              const BottomNavigation(currentNavIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'vidsell',
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        2.width,
        Image.asset(
          "assets/images/Vidsell logo 2.png",
          width: 36.w,
          height: 36.h,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(24.r),
            onTap: _openSearchPage,
            child: SizedBox(
              height: 37.h,
              child: IgnorePointer(
                child: TextField(
                  enabled: false,
                  style: AppTextStyle.primaryText.copyWith(
                    color: AppColor.tertiaryTextColor,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        height: 20.h,
                        width: 20.w,
                        colorFilter: const ColorFilter.mode(
                          AppColor.tertiaryTextColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    hintText: context.l10n.searchProduct,
                    hintStyle: AppTextStyle.primaryText.copyWith(
                      color: AppColor.tertiaryTextColor,
                      fontSize: 14.sp,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColor.bgSurfaceColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        10.width,
        InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: _openFilterPage,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: SvgPicture.asset(
              'assets/images/menu.svg',
              height: 24.h,
              width: 24.w,
              colorFilter: const ColorFilter.mode(
                AppColor.activeColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 140.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerCount,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(color: AppColor.bgSurfaceColor),
              );
            },
          ),
          Positioned(
            right: 12.w,
            top: 12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${_bannerIndex + 1}/$_bannerCount',
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CategoryItem.categories.length,
        separatorBuilder: (context, index) => 12.width,
        itemBuilder: (context, index) {
          final category = CategoryItem.categories[index];
          final isActive = _selectedCategory == index;

          return InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => _onCategoryTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColor.bgSurfaceColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: isActive
                        ? Border.all(color: AppColor.activeColor, width: 1.5.w)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: category.iconPath.endsWith('svg')
                      ? SvgPicture.asset(
                          fit: BoxFit.cover,
                          category.iconPath,
                          height: 32.h,
                          width: 32.w,
                        )
                      : Image.asset(
                          fit: BoxFit.cover,
                          category.iconPath,
                          height: 38.h,
                          width: 38.w,
                        ),
                ),
                6.height,
                SizedBox(
                  width: 60.w,
                  child: Text(
                    category.localizedLabel(context.l10n),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.primaryText.copyWith(
                      color: isActive ? AppColor.activeColor : Colors.white,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.premium,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            context.l10n.newListings,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.activeColor,
              fontSize: 13.sp,
              decoration: TextDecoration.underline,
              decorationColor: AppColor.activeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsGrid() {
    if (_isLoadingListings) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_listingsError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Text(
                _listingsError!,
                textAlign: TextAlign.center,
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.secondaryTextColor,
                  fontSize: 13.sp,
                ),
              ),
              TextButton(
                onPressed: _loadListings,
                child: Text(context.l10n.retryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: Text(
              context.l10n.noMatchingListings,
              style: AppTextStyle.primaryText.copyWith(
                color: AppColor.secondaryTextColor,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.62,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(
          key: ValueKey('discover-${_listings[index].id}'),
          product: _listings[index],
          playbackGroup: _videoRowGroups.putIfAbsent(index ~/ 2, Object.new),
        ),
        childCount: _listings.length,
      ),
    );
  }
}

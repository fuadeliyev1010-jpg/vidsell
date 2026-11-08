import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/listing_filter.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/features/discover/pages/filter_page.dart';
import 'package:vidsell/features/discover/pages/selected_items_page.dart';
import 'package:vidsell/features/discover/widgets/map_view.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class CategoryResultsPage extends StatefulWidget {
  final String title;
  final String? categoryId;
  final String? subcategoryId;
  final ListingFilter? filter;

  const CategoryResultsPage({
    super.key,
    this.title = 'Telefonlar',
    this.categoryId,
    this.subcategoryId,
    this.filter,
  });

  @override
  State<CategoryResultsPage> createState() => _CategoryResultsPageState();
}

class _CategoryResultsPageState extends State<CategoryResultsPage> {
  static const _brands = [
    'Apple iPhone',
    'Samsung',
    'Xiaomi',
    'Honor',
    'Huawei',
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late ListingFilter? _activeFilter = widget.filter;
  late final HomeRepository _homeRepository;
  List<Product> _allListings = const [];
  bool _isLoadingListings = true;
  String? _loadError;
  int _activeFilterCount = 1;
  String _selectedBrand = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _homeRepository = context.read<HomeRepository>();
    _loadListings();
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadListings({ListingFilter? filter}) async {
    setState(() {
      _isLoadingListings = true;
      _loadError = null;
    });
    final activeFilter = filter ?? _activeFilter;
    try {
      final page = await _homeRepository.fetchListings(
        limit: 50,
        categoryId: activeFilter?.categoryId ?? widget.categoryId,
        subcategoryId: activeFilter?.subcategoryId ?? widget.subcategoryId,
        cityId: activeFilter?.cityId,
        sellerType: activeFilter?.sellerType,
      );
      if (!mounted) return;
      setState(() {
        _allListings = page.items
            .map((item) => item.product)
            .whereType<Product>()
            .toList(growable: false);
        _isLoadingListings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = context.l10n.homeLoadError;
        _isLoadingListings = false;
      });
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredListings {
    final query = _searchQuery.toLowerCase();
    return _allListings
        .where((item) {
          if (_selectedBrand != 'all' &&
              !item.brand.toLowerCase().contains(
                _selectedBrand.toLowerCase(),
              ) &&
              !item.title.toLowerCase().contains(
                _selectedBrand.toLowerCase(),
              )) {
            return false;
          }
          if (query.isNotEmpty &&
              !item.title.toLowerCase().contains(query) &&
              !(item.city ?? '').toLowerCase().contains(query)) {
            return false;
          }
          if (_activeFilter?.cityId != null &&
              item.cityId != _activeFilter!.cityId) {
            return false;
          }
          if (_activeFilter?.minPrice != null &&
              item.price < _activeFilter!.minPrice!) {
            return false;
          }
          if (_activeFilter?.maxPrice != null &&
              item.price > _activeFilter!.maxPrice!) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  Future<void> _openFilter() async {
    final result = await context.goTo<ListingFilter>(
      FilterPage(
        category: CategoryItem(
          id: widget.categoryId ?? 'electronics',
          label: widget.title,
          iconPath: 'assets/images/computer 2.png',
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _activeFilter = result;
        _activeFilterCount = 1;
        if (result.minPrice != null) _activeFilterCount++;
        if (result.maxPrice != null) _activeFilterCount++;
        if (result.cityName != null) _activeFilterCount++;
      });
      _loadListings(filter: result);
    }
  }

  void _openMap(List<Product> listings) {
    context.goTo(
      FullScreenMapPage(
        listings: listings.isNotEmpty ? listings : _allListings,
      ),
      fullscreenDialog: true,
    );
  }

  void _openFavorites() {
    context.goTo(const SelectedItemsPage());
  }

  @override
  Widget build(BuildContext context) {
    final listings = _filteredListings;
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(
        title: widget.title,
        appBarHeight: 55.h,
        spaceBetweenTitleAndDivider: 14.h,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 24.h,
                          ),
                          child: _buildSearchBarAndActions(),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildBrandChipsRow()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 18.h),
                          child: Text(
                            context.l10n.vipListings,
                            style: AppTextStyle.primaryText.copyWith(
                              color: AppColor.secondaryTextColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      if (_isLoadingListings)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      else if (_loadError != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              children: [
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.primaryText.copyWith(
                                    color: AppColor.secondaryTextColor,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _loadListings(),
                                  child: Text(context.l10n.retryAgain),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (listings.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
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
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15.w,
                                  mainAxisSpacing: 24.h,
                                  childAspectRatio: 164.w / 268.h,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  ProductCard(product: listings[index]),
                              childCount: listings.length,
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(child: 24.height),
                    ],
                  ),
                  Positioned(bottom: 18.h, child: _buildMapButton(listings)),
                ],
              ),
            ),
            const BottomNavigation(currentNavIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(List<Product> listings) {
    return Material(
      color: AppColor.activeColor,
      borderRadius: BorderRadius.circular(24.r),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      child: InkWell(
        onTap: () => _openMap(listings),
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, color: Colors.black, size: 18.sp),
              5.width,
              Text(
                context.l10n.map,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBarAndActions() {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 37.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.bgSurfaceColor,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: _searchFocus.hasFocus
                    ? AppColor.activeColor
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.searchProduct,
                hintStyle: AppTextStyle.primaryText.copyWith(
                  color: AppColor.tertiaryTextColor,
                  fontSize: 14.sp,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 14.w, right: 9.w),
                  child: Center(
                    widthFactor: 1,
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: const ColorFilter.mode(
                        AppColor.secondaryTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 43.w,
                  minHeight: 0,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
        ),
        8.width,
        InkWell(
          onTap: _openFavorites,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFEF4444),
              size: 24.sp,
            ),
          ),
        ),
        8.width,
        InkWell(
          onTap: _openFilter,
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.all(6.w),
                child: SvgPicture.asset(
                  'assets/images/menu.svg',
                  width: 22.sp,
                  height: 22.sp,
                  colorFilter: const ColorFilter.mode(
                    AppColor.activeColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 2.w,
                  top: 2.h,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14.w,
                      minHeight: 14.w,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandChipsRow() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length + 1,
        separatorBuilder: (_, _) => 8.width,
        itemBuilder: (context, index) {
          final brand = index == _brands.length ? 'all' : _brands[index];
          final isSelected = _selectedBrand == brand;
          return InkWell(
            onTap: () => setState(() => _selectedBrand = brand),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.bgSurfaceColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.bgSurfaceColor),
              ),
              child: Center(
                child: Text(
                  brand == 'all' ? context.l10n.all : brand,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

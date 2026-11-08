import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/cabinet/pages/edit_profile_page.dart';
import 'package:vidsell/features/cabinet/pages/settings_page.dart';
import 'package:vidsell/features/cabinet/pages/wallet_page.dart';
import 'package:vidsell/features/cabinet/widgets/category_selection_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/widgets/inactive_listing_action_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/widgets/inactive_listing_card.dart';
import 'package:vidsell/features/cabinet/widgets/sort_selection_bottom_sheet.dart';
import 'package:vidsell/features/new_listing/pages/new_listing_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/models/user/user.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/cabinet/pages/business_dashboard_page.dart';
import 'package:vidsell/features/cabinet/pages/business_login_page.dart';
import 'package:vidsell/features/cabinet/pages/business_create_page.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class CabinetPage extends StatefulWidget {
  final ProfileRepository? profileRepository;

  const CabinetPage({super.key, this.profileRepository});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ProfileRepository _profileRepository;
  late final BusinessRepository _businessRepository;
  late final UserListingRepository _userListingRepository;
  late final StatusCountRepository _statusCountRepository;
  Map<ProductStatus, int> _statusCounts = const {};
  String? _selectedCategory;
  String? _selectedSortOption;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  int _lastSelectedTabIndex = 0;

  // Selection state for inactive listing item
  String? _selectedListingId;
  List<Product> _userListings = const [];
  Map<int, List<Product>> _listingsByTab = const {};
  bool _isLoadingListings = true;
  String? _listingsError;
  late Future<User> _profileFuture;
  User? _profile;
  MyStore? _myStore;
  bool _isLoadingMyStore = true;
  Object? _myStoreError;

  @override
  void initState() {
    super.initState();
    _profileRepository =
        widget.profileRepository ?? context.read<ProfileRepository>();
    _businessRepository = context.read<BusinessRepository>();
    _userListingRepository = context.read<UserListingRepository>();
    _statusCountRepository = context.read<StatusCountRepository>();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _profileFuture = _profileRepository.fetchProfile();
    _loadMyListings();
    _loadStatusCounts();
    _loadMyStore();
  }

  Future<void> _loadStatusCounts() async {
    try {
      final counts = await _statusCountRepository.fetchStatusCounts();
      if (!mounted) return;
      setState(() {
        _statusCounts = {for (final item in counts) item.status: item.count};
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load listing counts: $error')),
        );
      }
    }
  }

  int _statusCount(int index) {
    if (_statusCounts.isEmpty) return _listingsForTab(index).length;
    final statuses = switch (index) {
      0 => const {ProductStatus.active},
      1 => const {ProductStatus.pendingPayment},
      2 => const {ProductStatus.inactive, ProductStatus.sold},
      3 => const {ProductStatus.rejected},
      4 => const {ProductStatus.underReview},
      _ => const <ProductStatus>{},
    };
    return statuses.fold(
      0,
      (total, status) => total + (_statusCounts[status] ?? 0),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    if (!_isSearchExpanded) return;
    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
    });
  }

  void _handleTabChanged() {
    if (_tabController.index == _lastSelectedTabIndex) return;
    _lastSelectedTabIndex = _tabController.index;
    _closeSearch();
  }

  void _focusSearch() {
    if (!_isSearchExpanded) setState(() => _isSearchExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _openCategorySelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelectionBottomSheet(
        onCategorySelected: (selectedCat) {
          setState(() {
            _selectedCategory = selectedCat;
          });
        },
      ),
    );
  }

  void _openSortSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortSelectionBottomSheet(
        selectedSort: _selectedSortOption,
        onSortSelected: (selectedSort) {
          setState(() {
            _selectedSortOption = selectedSort;
          });
        },
      ),
    );
  }

  Future<void> _showItemActionBottomSheet(Product listing) async {
    final canChangeStatus =
        listing.status == ProductStatus.active ||
        listing.status == ProductStatus.sold;
    final nextStatus = listing.status == ProductStatus.active
        ? ProductStatus.sold
        : ProductStatus.active;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => InactiveListingActionBottomSheet(
        statusActionLabel: listing.status == ProductStatus.active
            ? context.l10n.pauseListing
            : context.l10n.activate,
        showStatusAction: canChangeStatus,
        onStatusChange: () => _changeListingStatus(listing.id, nextStatus),
        onDelete: () => _deleteListing(listing.id),
      ),
    );
    if (mounted) setState(() => _selectedListingId = null);
  }

  Future<void> _loadMyListings() async {
    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });
    try {
      const tabStatuses = [
        ProductStatus.active,
        ProductStatus.pendingPayment,
        ProductStatus.sold,
        ProductStatus.rejected,
        ProductStatus.underReview,
      ];
      final tabListings = await Future.wait(
        tabStatuses.map(
          (status) => _userListingRepository.fetchMyListings(status: status),
        ),
      );
      if (!mounted) return;
      setState(() {
        _listingsByTab = {
          for (var index = 0; index < tabListings.length; index++)
            index: tabListings[index],
        };
        _userListings = tabListings.expand((listings) => listings).toList();
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

  Future<void> _changeListingStatus(
    String listingId,
    ProductStatus status,
  ) async {
    try {
      await _userListingRepository.updateListingStatus(listingId, status);
      await _loadMyListings();
      if (!mounted) return;
      setState(() {
        _selectedListingId = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    }
  }

  Future<void> _deleteListing(String listingId) async {
    try {
      await _userListingRepository.deleteListing(listingId);
      if (!mounted) return;
      setState(() {
        _userListings = _userListings
            .where((listing) => listing.id != listingId)
            .toList(growable: false);
        _listingsByTab = {
          for (final entry in _listingsByTab.entries)
            entry.key: entry.value
                .where((listing) => listing.id != listingId)
                .toList(growable: false),
        };
        _selectedListingId = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    }
  }

  Future<void> _openEditProfile() async {
    await context.goTo(const EditProfilePage());
    if (!mounted) return;
    setState(() {
      _profileFuture = _profileRepository.fetchProfile();
    });
  }

  Future<void> _openStoreApplication() async {
    final isMock = context.read<AppConfig>().useMockBackend;
    final store = isMock
        ? await context.goTo<MyStore>(const BusinessLoginPage())
        : await context.goTo<MyStore>(
            BusinessCreatePage(phoneNumber: _profile?.phoneNumber ?? ''),
          );
    if (!mounted || store == null) return;
    setState(() => _myStore = store);
    _loadMyStore();
  }

  Future<void> _openBusinessDashboard() async {
    final store = _myStore;
    if (store == null) return;
    await context.goTo(BusinessDashboardPage(store: store));
    if (mounted) _loadMyStore();
  }

  Future<void> _loadMyStore() async {
    setState(() {
      _isLoadingMyStore = true;
      _myStoreError = null;
    });
    try {
      final store = await _businessRepository.fetchMyStore();
      if (!mounted) return;
      setState(() => _myStore = store);
    } catch (error) {
      if (!mounted) return;
      setState(() => _myStoreError = error);
    } finally {
      if (mounted) setState(() => _isLoadingMyStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    FutureBuilder<User>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        final profile = snapshot.data ?? _profile;
                        if (profile == null) {
                          return _buildHeaderSection(null);
                        }
                        _profile = profile;
                        return _buildHeaderSection(profile);
                      },
                    ),
                    16.height,
                    _buildWalletAndStatsCard(),
                    16.height,
                    _buildMarketCard(),
                    16.height,
                    _buildTabBar(),
                    16.height,
                    _buildFilterSection(),
                    16.height,
                    // FIX: TabBarView needs a bounded height inside a scroll view
                    SizedBox(
                      height: 300.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildListingsTab(
                            0,
                            context.l10n.emptyActiveListings,
                          ),
                          _buildListingsTab(
                            1,
                            context.l10n.emptyPendingPaymentListings,
                          ),
                          _buildListingsTab(
                            2,
                            context.l10n.emptyInactiveListings,
                          ),
                          _buildListingsTab(
                            3,
                            context.l10n.emptyRejectedListings,
                          ),
                          _buildListingsTab(
                            4,
                            context.l10n.emptyReviewListings,
                          ),
                        ],
                      ),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildMarketCard() {
    if (_isLoadingMyStore) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.activeColor),
      );
    }
    if (_myStoreError != null) {
      return Center(
        child: TextButton(
          onPressed: _loadMyStore,
          child: Text(context.l10n.genericError),
        ),
      );
    }
    final store = _myStore;
    final hasMarket = store != null;
    final approved = store?.status == 'ACTIVE';
    final statusColor = approved ? AppColor.success : const Color(0xFFFFA500);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hasMarket
            ? [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        store.displayName,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: statusColor),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _storeStatusLabel(store),
                        style: TextStyle(color: statusColor, fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
                12.height,
                Text(
                  _storeStatusDescription(store),
                  style: AppTextStyle.mutedText.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                12.height,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    height: 42.h,
                    text: context.l10n.goToStore,
                    icon: Icons.swap_horiz,
                    color: approved
                        ? AppColor.activeColor
                        : AppColor.bgElavated,
                    onPressed: _openBusinessDashboard,
                  ),
                ),
              ]
            : [
                Text(
                  context.l10n.noStore,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                12.height,
                Text(
                  context.l10n.createStorePrompt,
                  style: AppTextStyle.mutedText.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                14.height,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    height: 44.h,
                    text: context.l10n.createStore,
                    icon: Icons.storefront_outlined,
                    onPressed: _openStoreApplication,
                  ),
                ),
              ],
      ),
    );
  }

  String _storeStatusLabel(MyStore store) => switch (store.status) {
    'APPLICATION' => context.l10n.storeStatusApplication,
    'ACTIVE' => context.l10n.storeApproved,
    'INACTIVE' => context.l10n.storeStatusInactive,
    'SUSPENDED' => context.l10n.storeStatusSuspended,
    'REJECTED' => context.l10n.storeStatusRejected,
    _ => context.l10n.storePendingApproval,
  };

  String _storeStatusDescription(MyStore store) {
    if (store.status == 'REJECTED' &&
        store.rejectionReason?.trim().isNotEmpty == true) {
      return '${context.l10n.storeStatusRejected}: ${store.rejectionReason}';
    }
    return switch (store.status) {
      'APPLICATION' => context.l10n.storeUnderReview,
      'ACTIVE' => context.l10n.storePanelActive,
      'INACTIVE' => context.l10n.storeStatusInactive,
      'SUSPENDED' => context.l10n.storeStatusSuspended,
      'REJECTED' => context.l10n.storeStatusRejected,
      _ => context.l10n.storeUnderReview,
    };
  }

  Widget _buildHeaderSection(User? profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColor.bgSurfaceColor,
            child: SvgPicture.asset('assets/icons/profile-2.svg'),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? context.l10n.userProfile,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                2.height,
                Text(
                  AppLocalizations.of(
                    context,
                  )!.accountIdLabel(profile?.id ?? '-'),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          _buildCircleIconButton(
            iconPath: 'assets/icons/solar_pen-linear.svg',
            onTap: () {
              _openEditProfile();
            },
          ),
          10.width,
          _buildCircleIconButton(
            iconPath: 'assets/icons/setting-2.svg',
            onTap: () {
              context.goTo(const SettingsPage());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: const BoxDecoration(
          color: AppColor.bgSurfaceColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: SvgPicture.asset(iconPath)),
      ),
    );
  }

  Widget _buildWalletAndStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/solar_wallet-linear.svg'),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.wallet,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      context.l10n.zeroBalance,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.goTo(const WalletPage());
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  context.l10n.topUpBalance,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: const Color(0xFF232C3A), thickness: 1.h),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/uil_analytics.svg'),
                12.width,
                Expanded(
                  child: Text(
                    context.l10n.efficiency,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 60.h,
      child: TabBar(
        dividerColor: Colors.transparent,
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColor.activeColor,
        indicatorWeight: 2.h,
        labelColor: AppColor.activeColor,
        unselectedLabelColor: Colors.grey.shade400,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: context.l10n.activeListingsCount(_statusCount(0))),
          Tab(text: context.l10n.paymentAwaiting(_statusCount(1))),
          Tab(text: context.l10n.inactiveListingsCount(_statusCount(2))),
          Tab(text: context.l10n.rejectedListingsCount(_statusCount(3))),
          Tab(text: context.l10n.moderationListingsCount(_statusCount(4))),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final bool hasActiveFilter =
        _selectedCategory != null || _selectedSortOption != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('cabinet-search-button'),
            behavior: HitTestBehavior.opaque,
            onTap: _isSearchExpanded ? null : _focusSearch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: _isSearchExpanded ? 196.w : 42.r,
              height: _isSearchExpanded ? 36.h : 38.r,
              padding: EdgeInsets.symmetric(horizontal: 6.5.w),
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: hasActiveFilter
                      ? AppColor.activeColor
                      : const Color(0xFF293240),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 20.w,
                    height: 20.h,
                  ),
                  if (_isSearchExpanded) ...[
                    6.width,
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) => setState(() {}),
                        onTapOutside: (_) => _closeSearch(),
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 11.sp,
                        ),
                        cursorColor: AppColor.activeColor,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchPlaceholder,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          8.width,
          _buildCategoryFilterChip(),
          8.width,
          _buildSortFilterChip(),
          12.width,
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _selectedSortOption = null;
              });
            },
            child: Text(
              context.l10n.clearFilter,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip() {
    final bool isSelected = _selectedCategory != null;

    return GestureDetector(
      key: const ValueKey('cabinet-category-filter'),
      onTap: _openCategorySelectionModal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColor.activeColor : const Color(0xFF293240),
          ),
        ),
        child: Row(
          children: [
            Text(
              isSelected ? _selectedCategory! : context.l10n.category,
              style: TextStyle(
                color: isSelected ? AppColor.activeColor : Colors.grey.shade300,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            4.width,
            if (isSelected)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  color: AppColor.activeColor,
                  size: 16.sp,
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortFilterChip() {
    final bool isSelected = _selectedSortOption != null;

    String displayLabel = context.l10n.sort;
    if (isSelected) {
      displayLabel = switch (_selectedSortOption) {
        'price_asc' => context.l10n.sortPriceLowest,
        'price_desc' => context.l10n.sortPriceHighest,
        'newest' => context.l10n.sortNewest,
        _ => context.l10n.sort,
      };
    }

    return GestureDetector(
      onTap: _openSortSelectionModal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColor.activeColor : const Color(0xFF293240),
          ),
        ),
        child: Row(
          children: [
            Text(
              displayLabel,
              style: TextStyle(
                color: isSelected ? AppColor.activeColor : Colors.grey.shade300,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            4.width,
            if (isSelected)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSortOption = null;
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  color: AppColor.activeColor,
                  size: 16.sp,
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }

  List<Product> _listingsForTab(int index) {
    return _listingsByTab[index] ?? const [];
  }

  Widget _buildListingsTab(int index, String emptyTitle) {
    if (_isLoadingListings) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.activeColor),
      );
    }

    if (_listingsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _listingsError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
            ),
            TextButton(
              onPressed: _loadMyListings,
              child: Text(context.l10n.retryAgain),
            ),
          ],
        ),
      );
    }
    final query = _searchController.text.trim().toLowerCase();
    final listings = _listingsForTab(index).where((product) {
      final textMatches =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.categoryDisplay.toLowerCase().contains(query) ||
          (product.city ?? '').toLowerCase().contains(query) ||
          product.price.toString().contains(query);
      final categoryMatches =
          _selectedCategory == null ||
          product.category?.code == _selectedCategory;
      return textMatches && categoryMatches;
    }).toList();

    DateTime sortDate(Product p) =>
        p.updatedAt ?? p.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    if (_selectedSortOption == 'price_asc') {
      listings.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSortOption == 'price_desc') {
      listings.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSortOption == 'newest') {
      listings.sort((a, b) => sortDate(b).compareTo(sortDate(a)));
    }

    if (listings.isEmpty) return _buildEmptyStateCard(emptyTitle);

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 165.w / 235.h,
      ),
      itemBuilder: (context, index) {
        final listing = listings[index];
        return InactiveListingCard(
          listing: listing,
          isSelected: _selectedListingId == listing.id,
          onTap: () {
            setState(() => _selectedListingId = listing.id);
            _showItemActionBottomSheet(listing);
          },
        );
      },
    );
  }

  Widget _buildEmptyStateCard(String title) {
    // Align keeps the card at its natural height inside the fixed-height TabBarView
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            14.height,
            Text(
              context.l10n.sellProductPrompt,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
            ),
            14.height,
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton.icon(
                onPressed: () => context.goTo(const NewListingPage()),
                icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
                label: Text(
                  context.l10n.createListing,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.bgElavated,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/app_icon_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/messages/pages/chat_detail_page.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/enums/seller_type.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/public_store_profile.dart';

class StorePage extends StatefulWidget {
  const StorePage({
    super.key,
    required this.storeName,
    this.sellerId,
    this.sellerAvatar,
    this.sellerType,
  });

  final String storeName;
  final String? sellerId;
  final String? sellerAvatar;
  final SellerType? sellerType;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final HomeRepository _homeRepository;
  late final BusinessRepository _businessRepository;
  List<Product> _listings = const [];
  PublicStoreProfile? _profile;
  bool _isIndividual = false;
  bool _isLoadingProfile = true;
  bool _isLoadingListings = true;
  bool _isBlocked = false;
  Object? _profileError;
  Object? _listingsError;

  String get _displayName =>
      _nonEmpty(_profile?.storeName) ??
      _nonEmpty(_profile?.fullName) ??
      widget.storeName;

  @override
  void initState() {
    super.initState();
    _homeRepository = context.read<HomeRepository>();
    _businessRepository = context.read<BusinessRepository>();
    _isIndividual = widget.sellerType == SellerType.individual;
    if (_isIndividual) _isLoadingProfile = false;
    _loadListings();
    if (!_isIndividual) _loadProfile();
  }

  String? _nonEmpty(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<void> _loadProfile() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
        _profileError = StateError('Seller ID is missing.');
      });
      return;
    }

    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });
    try {
      final profile = await _businessRepository.fetchPublicStore(sellerId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isIndividual = profile == null;
        _isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _profileError = error;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadListings() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      setState(() {
        _listings = const [];
        _isLoadingListings = false;
      });
      return;
    }

    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });
    try {
      final listings = <Product>[];
      var pageNumber = 1;
      var isLastPage = false;
      do {
        final page = await _homeRepository.fetchListings(
          page: pageNumber,
          size: 50,
          sellerId: sellerId,
        );
        listings.addAll(
          page.items
              .map((item) => item.product)
              .whereType<Product>()
              .where((product) => product.status == ProductStatus.active),
        );
        isLastPage = page.last;
        if (!isLastPage &&
            (page.page != pageNumber - 1 || pageNumber >= page.totalPages)) {
          throw StateError(
            'Seller listing pagination returned an invalid page.',
          );
        }
        pageNumber++;
      } while (!isLastPage);

      if (!mounted) return;
      setState(() {
        _listings = listings;
        _isLoadingListings = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _listingsError = error;
        _isLoadingListings = false;
      });
    }
  }

  Future<void> _toggleFollowing() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty || _isIndividual) return;
    final following = context.read<FollowingCubit>();
    try {
      await following.toggle(
        storeId: sellerId,
        enabled: !following.isFollowing(sellerId),
        item: EngagementItem(
          id: sellerId,
          title: _displayName,
          imageUrl: _profile?.avatarUrl ?? widget.sellerAvatar,
          subtitle: _displayName,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _toggleBlocked() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) return;
    try {
      await context.read<EngagementRepository>().blockUser(sellerId);
      if (mounted) setState(() => _isBlocked = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: _isBlocked
                  ? Center(child: Text(context.l10n.blockedSeller))
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCoverAndAvatar(),
                          12.height,
                          _buildProfileHeader(),
                          if (_isLoadingProfile) ...[
                            12.height,
                            const LinearProgressIndicator(),
                          ] else if (_profileError != null) ...[
                            8.height,
                            TextButton(
                              onPressed: _loadProfile,
                              child: Text(context.l10n.homeLoadError),
                            ),
                          ],
                          16.height,
                          _buildActionButtons(),
                          if (_isIndividual) ...[
                            16.height,
                            _buildIndividualListingCount(),
                          ] else if (_profile != null) ...[
                            if (_hasStats) ...[16.height, _buildStatsRow()],
                            if (_nonEmpty(_profile?.description) != null) ...[
                              16.height,
                              _buildDescription(_profile!.description!.trim()),
                            ],
                            if (_hasWorkingHours) ...[
                              16.height,
                              _buildWorkingHours(),
                            ],
                          ],
                          20.height,
                          Text(
                            context.l10n.storeListings,
                            style: AppTextStyle.primaryText.copyWith(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          14.height,
                          _buildListingsGrid(),
                          24.height,
                        ],
                      ),
                    ),
            ),
            const BottomNavigation(currentNavIndex: 1),
          ],
        ),
      ),
    );
  }

  bool get _hasStats =>
      _profile?.products != null ||
      _profile?.followers != null ||
      _profile?.views != null;

  bool get _hasWorkingHours =>
      _profile?.open24Hours == true ||
      _nonEmpty(_profile?.opensAt) != null ||
      _nonEmpty(_profile?.closesAt) != null ||
      (_profile?.workingHours.isNotEmpty ?? false);

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: context.goBack,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          const Spacer(),
          AppIconButton(
            width: 24.w,
            height: 24.h,
            radius: 100.r,
            iconPath: 'assets/icons/qlementine-icons_menu-dots-16.svg',
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: const Color(0xFF151921),
              builder: (sheetContext) => SafeArea(
                child: ListTile(
                  leading: const Icon(Icons.block, color: Colors.white),
                  title: Text(
                    context.l10n.blockUser,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _toggleBlocked();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverAndAvatar() {
    final banner = _profile?.bannerUrl;
    final avatar =
        _profile?.avatarUrl ?? _profile?.logoUrl ?? widget.sellerAvatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C222E),
            borderRadius: BorderRadius.circular(12.r),
            image: banner == null
                ? null
                : DecorationImage(
                    image: NetworkImage(banner),
                    fit: BoxFit.cover,
                    onError: (_, _) {},
                  ),
          ),
        ),
        Positioned(
          bottom: -28.h,
          left: 8.w,
          child: Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: const Color(0xFF252C39),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.primaryColor, width: 3.w),
              image: avatar == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                      onError: (_, _) {},
                    ),
            ),
            child: avatar == null
                ? Icon(
                    _isIndividual ? Icons.person_outline : Icons.storefront,
                    color: Colors.white54,
                    size: 28.sp,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, top: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayName,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_isIndividual)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                context.l10n.individualSellerLabel,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white60,
                  fontSize: 13.sp,
                ),
              ),
            )
          else if (_nonEmpty(_profile?.category) != null)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                _profile!.category!,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white60,
                  fontSize: 13.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final sellerId = widget.sellerId;
    final showFollow = !_isIndividual && _profile != null;
    final isFollowing =
        showFollow &&
        sellerId != null &&
        context.watch<FollowingCubit>().isFollowing(sellerId);
    return Row(
      children: [
        if (showFollow) ...[
          Expanded(
            child: AppButton(
              side: const BorderSide(color: AppColor.activeColor),
              text: isFollowing
                  ? context.l10n.followingStatus
                  : context.l10n.follow,
              onPressed: _toggleFollowing,
              color: isFollowing
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColor.activeColor,
              textColor: isFollowing ? AppColor.activeColor : Colors.white,
              height: 44.h,
              icon: isFollowing ? null : Icons.add,
            ),
          ),
          10.width,
        ],
        Expanded(
          child: AppButton(
            text: 'Mesaj yaz',
            onPressed: () => context.goTo(
              ChatDetailPage(
                userName: _displayName,
                userAvatar: _profile?.avatarUrl ?? widget.sellerAvatar,
                sellerId: widget.sellerId,
              ),
            ),
            color: Colors.transparent,
            textColor: AppColor.activeColor,
            side: const BorderSide(color: AppColor.activeColor),
            height: 44.h,
            icon: Icons.send_outlined,
            iconTrailing: true,
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualListingCount() => Text(
    '${_listings.length} ${context.l10n.listingCount}',
    style: AppTextStyle.primaryText.copyWith(
      color: Colors.white70,
      fontSize: 13.sp,
    ),
  );

  Widget _buildStatsRow() {
    final entries = <(int, String)>[
      if (_profile?.products case final int products)
        (products, context.l10n.listingCount),
      if (_profile?.followers case final int followers)
        (followers, context.l10n.followers),
      if (_profile?.views case final int views) (views, context.l10n.views),
    ];
    return Row(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) 8.width,
          Expanded(child: _statCard(entries[index].$1, entries[index].$2)),
        ],
      ],
    );
  }

  Widget _statCard(int value, String label) => Container(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        2.height,
        Text(
          label,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white60,
            fontSize: 11.sp,
          ),
        ),
      ],
    ),
  );

  Widget _buildDescription(String text) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      text,
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white70,
        fontSize: 13.sp,
        height: 1.4,
      ),
    ),
  );

  Widget _buildWorkingHours() {
    final profile = _profile!;
    final values = <String>[];
    if (profile.open24Hours == true) {
      values.add('24/7');
    } else {
      final opens = _nonEmpty(profile.opensAt);
      final closes = _nonEmpty(profile.closesAt);
      if (opens != null || closes != null) {
        values.add([opens, closes].whereType<String>().join(' – '));
      }
      for (final hour in profile.workingHours) {
        final day = _nonEmpty(hour['day']?.toString());
        final start = _nonEmpty(hour['opens']?.toString());
        final end = _nonEmpty(hour['closes']?.toString());
        final schedule = [start, end].whereType<String>().join(' – ');
        if (day != null && schedule.isNotEmpty) values.add('$day: $schedule');
      }
    }
    if (values.isEmpty) return const SizedBox.shrink();
    return Text(
      values.join('\n'),
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white60,
        fontSize: 12.sp,
      ),
    );
  }

  Widget _buildListingsGrid() {
    if (_isLoadingListings) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listingsError != null) {
      return Center(
        child: TextButton(
          onPressed: _loadListings,
          child: Text(context.l10n.homeLoadError, textAlign: TextAlign.center),
        ),
      );
    }
    if (_listings.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noResults,
          style: AppTextStyle.primaryText.copyWith(
            color: AppColor.secondaryTextColor,
            fontSize: 13.sp,
          ),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.62,
      ),
      itemCount: _listings.length,
      itemBuilder: (context, index) => ProductCard(product: _listings[index]),
    );
  }
}

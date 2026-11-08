import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/app_icon_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/home/widgets/share_bottom_sheet.dart';
import 'package:vidsell/features/home/widgets/store_location_bottom_sheet.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/messages/pages/chat_detail_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class StorePage extends StatefulWidget {
  const StorePage({
    super.key,
    this.storeName = 'Safiyyə Səfərova',
    this.sellerId,
    this.sellerAvatar,
    this.category,
    this.listingCount = 48,
    this.followerCount = 71,
    this.viewCount = 24561,
    this.description,
    this.location,
  });

  final String storeName;
  final String? sellerId;
  final String? sellerAvatar;
  final String? category;
  final int listingCount;
  final int followerCount;
  final int viewCount;
  final String? description;
  final String? location;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _descriptionExpanded = false;
  bool _isBlocked = false; // Block state
  bool _isWorkHoursExpanded = false;
  late final HomeRepository _homeRepository;
  List<Product> _listings = const [];
  bool _isLoadingListings = true;
  Object? _listingsError;

  String get _category => widget.category ?? context.l10n.categoryElectronics;
  String get _description =>
      widget.description ?? context.l10n.storeDescriptionPlaceholder;
  String get _location =>
      widget.location ?? context.l10n.storeLocationPlaceholder;

  @override
  void initState() {
    super.initState();
    _homeRepository = context.read<HomeRepository>();
    _loadListings();
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
      String? cursor;
      do {
        final page = await _homeRepository.fetchListings(
          cursor: cursor,
          limit: 50,
          sellerId: sellerId,
        );
        listings.addAll(
          page.items.map((item) => item.product).whereType<Product>(),
        );
        if (page.nextCursor == cursor && page.nextCursor != null) {
          throw StateError('Seller listings returned a repeated cursor.');
        }
        cursor = page.nextCursor;
      } while (cursor != null);

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
    if (sellerId == null || sellerId.isEmpty) return;
    final following = context.read<FollowingCubit>();
    try {
      await following.toggle(
        storeId: sellerId,
        enabled: !following.isFollowing(sellerId),
        item: EngagementItem(
          id: sellerId,
          title: widget.storeName,
          imageUrl: widget.sellerAvatar,
          subtitle: widget.storeName,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.favoritesUpdateFailed)),
      );
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
                  ? _buildBlockedView()
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCoverAndAvatar(),
                          12.height,
                          _buildStoreHeader(),
                          16.height,
                          _buildActionButtons(),
                          16.height,
                          _buildStatsRow(),
                          16.height,
                          _buildDescription(),
                          16.height,
                          _buildContactInfo(),
                          20.height,
                          _buildListingsSectionTitle(),
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
          if (_isBlocked) ...[
            const Spacer(),
            Text(
              context.l10n.userProfile,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          if (!_isBlocked)
            AppIconButton(
              width: 24.w,
              height: 24.h,
              radius: 100.r,
              iconPath: 'assets/icons/solar_upload-minimalistic-linear.svg',
              backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
              onPressed: () => showShareBottomSheet(
                context,
                sellerName: widget.storeName,
                link: 'shadbsh',
              ),
            ),
          if (!_isBlocked) 8.width,
          AppIconButton(
            width: 24.w,
            height: 24.h,
            radius: 100.r,
            iconPath: 'assets/icons/qlementine-icons_menu-dots-16.svg',
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151921),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isBlocked ? Icons.person_add_outlined : Icons.block,
                  color: Colors.white,
                ),
                title: Text(
                  _isBlocked
                      ? context.l10n.unblockUser
                      : context.l10n.blockUser,
                  style: AppTextStyle.primaryText.copyWith(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _toggleBlocked();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.white),
                title: Text(
                  context.l10n.reportUser,
                  style: AppTextStyle.primaryText.copyWith(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.actionNotAvailable)),
                  );
                },
              ),
              8.height,
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleBlocked() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) return;
    if (_isBlocked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.actionNotAvailable)));
      return;
    }
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

  // Bloklanmış Profil Görünüşü
  Widget _buildBlockedView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF1C222E),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.block, color: Colors.white38, size: 20.sp),
              ),
              12.width,
              Text(
                widget.storeName,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          20.height,
          Text(
            context.l10n.blockedSeller,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverAndAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Positioned(
          bottom: -28.h,
          left: 8.w,
          child: Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.primaryColor, width: 3.w),
            ),
            child: Icon(Icons.storefront, color: Colors.black45, size: 28.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, top: 32.h),
      child: RichText(
        text: TextSpan(
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: widget.storeName),
            TextSpan(
              text: '  ·  $_category',
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white60,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final sellerId = widget.sellerId;
    final isFollowing =
        sellerId != null &&
        context.watch<FollowingCubit>().isFollowing(sellerId);
    return Row(
      children: [
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
        Expanded(
          child: AppButton(
            text: 'Mesaj yaz',
            onPressed: () {
              context.goTo(
                ChatDetailPage(
                  userName: widget.storeName,
                  userAvatar: widget.sellerAvatar,
                  sellerId: widget.sellerId,
                ),
              );
            },
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            widget.listingCount.toString(),
            context.l10n.listingCount,
          ),
        ),
        8.width,
        Expanded(
          child: _statCard(
            widget.followerCount.toString(),
            context.l10n.followers,
          ),
        ),
        8.width,
        Expanded(
          child: _statCard(_formatCount(widget.viewCount), context.l10n.views),
        ),
      ],
    );
  }

  String _formatCount(int value) {
    if (value >= 1000) {
      final formatted = (value / 1000).toStringAsFixed(
        value % 1000 == 0 ? 0 : 1,
      );
      return '$formatted K';
    }
    return value.toString();
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
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
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _description,
            maxLines: _descriptionExpanded ? null : 3,
            overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white70,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          8.height,
          GestureDetector(
            onTap: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                _descriptionExpanded
                    ? context.l10n.storeShowLess
                    : context.l10n.storeShowMore,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Contact Info ─────────────────────────────────────────────────────────

  Widget _buildContactInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildContactRow(
            iconPath: 'assets/icons/Store1.svg',
            text: _location,
            onTap: () => StoreLocationBottomSheet.show(
              context,
              storeName: widget.storeName,
              location: _location,
              category: _category,
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColor.activeColor,
              size: 20.sp,
            ),
          ),
          _buildContactDivider(),
          _buildContactRow(
            iconPath: 'assets/icons/Store2.svg',
            text: '+994 123456789',
          ),
          _buildContactDivider(),
          _buildContactRow(
            iconPath: 'assets/icons/Store3.svg',
            text: 'tiktok.com',
          ),
          _buildContactDivider(),
          _buildContactRow(
            iconPath: 'assets/icons/Store4.svg',
            text: 'WhatsApp',
          ),
          _buildContactDivider(),
          _buildWorkHoursRow(context),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required String iconPath,
    required String text,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
            alignment: Alignment.center,
            child: SvgPicture.asset(iconPath, height: 16.h, width: 16.w),
          ),
          12.width,
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: content,
      );
    }
    return content;
  }

  Widget _buildWorkHoursRow(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12.r),
        bottomRight: Radius.circular(12.r),
      ),
      onTap: () => setState(() => _isWorkHoursExpanded = !_isWorkHoursExpanded),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/Store5.svg',
                    height: 16.h,
                    width: 16.w,
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.workHours,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                      2.height,
                      Row(
                        children: [
                          Text(
                            context.l10n.storeClosed,
                            style: AppTextStyle.primaryText.copyWith(
                              color: const Color(0xFFF87171),
                              fontSize: 11.sp,
                            ),
                          ),
                          4.width,
                          Text(
                            '· ${AppLocalizations.of(context)!.storeOpensAt('10:00')}',
                            style: AppTextStyle.primaryText.copyWith(
                              color: Colors.white60,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isWorkHoursExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white60,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildWorkHoursSchedule(context),
            crossFadeState: _isWorkHoursExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHoursSchedule(BuildContext context) {
    final l10n = context.l10n;
    final closed = l10n.storeClosed;
    final hours = [
      (l10n.weekdayMonday, '09:00 – 18:00'),
      (l10n.weekdayTuesday, '09:00 – 18:00'),
      (l10n.weekdayWednesday, '09:00 – 18:00'),
      (l10n.weekdayThursday, '09:00 – 18:00'),
      (l10n.weekdayFriday, '09:00 – 18:00'),
      (l10n.weekdaySaturday, closed),
      (l10n.weekdaySunday, closed),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(58.w, 0, 14.w, 12.h),
      child: Column(
        children: hours
            .map(
              (h) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.$1,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white60,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      h.$2,
                      style: AppTextStyle.primaryText.copyWith(
                        color: h.$2 == closed
                            ? const Color(0xFFF87171)
                            : Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildContactDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.06),
      indent: 14.w,
      endIndent: 14.w,
    );
  }

  // ─── Listings Grid ────────────────────────────────────────────────────────

  Widget _buildListingsSectionTitle() {
    return Text(
      context.l10n.storeListings,
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
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

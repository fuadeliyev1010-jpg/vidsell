import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/call_seller.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/special_text_field.dart';
import 'package:vidsell/features/discover/widgets/product_card.dart';
import 'package:vidsell/features/home/repositories/listing_detail_repository.dart';
import 'package:vidsell/features/home/page/report_listing_page.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/models/product/product.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ProductDetailsSheet extends StatefulWidget {
  const ProductDetailsSheet({
    super.key,
    this.listing,
    this.price,
    this.title = 'Apple iPhone 17 Pro 256GB Cosmic Orange MG7L4LL/A',
    this.categoryLabel,
    this.city,
    this.category,
    this.subCategory,
    this.quickReplies,
    this.onCall,
    this.onMessage,
    this.onSend,
    this.onReport,
    this.onBlock,
  });

  final Product? listing;
  final String? price;
  final String title;
  final String? categoryLabel;
  final String? city;
  final String? category;
  final String? subCategory;
  final List<String>? quickReplies;
  final VoidCallback? onCall;
  final ValueChanged<String>? onMessage;
  final ValueChanged<String>? onSend;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Product? _listing;

  // Once true, stays true — the point is to free up room for the
  // keyboard, and flipping back and forth every time focus blips
  // (e.g. tapping a quick-reply chip refocuses the field) would make
  // the sheet jump around under the user's thumb.
  bool _isChatMode = false;

  String get _price {
    final listing = _listing;
    if (listing == null) {
      return widget.price ??
          CurrencyFormatter.formatPrice(2890.24, fallbackCurrencyCode);
    }
    return CurrencyFormatter.formatPrice(listing.price, listing.currency);
  }

  String get _title => _listing?.title ?? widget.title;
  String get _city =>
      _listing?.city ?? widget.city ?? context.l10n.cityIstanbul;
  String get _category => widget.category ?? context.l10n.categoryElectronics;
  String get _subCategory => widget.subCategory ?? context.l10n.categoryPhones;
  String get _categoryLabel =>
      widget.categoryLabel ?? context.l10n.allCategoryItems('Apple iPhone');
  List<String> get _quickReplies =>
      widget.quickReplies ??
      [context.l10n.sellerGreetingCurrent, context.l10n.sellerGreetingInterest];

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
    _controller = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus && !_isChatMode) {
          setState(() => _isChatMode = true);
        }
      });
    _loadListingDetail();
  }

  Future<void> _loadListingDetail() async {
    final initialListing = _listing;
    if (initialListing == null || initialListing.id.isEmpty) return;
    final repository = context.read<ListingDetailRepository?>();
    if (repository == null) return;
    try {
      final detail = await repository.fetchListing(initialListing.id);
      if (!mounted) return;
      setState(() => _listing = detail);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendQuickReply(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _focusNode.requestFocus();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.onMessage != null) {
      widget.onMessage!(text);
    } else {
      widget.onSend?.call(text);
    }
    _controller.clear();
  }

  void _messageSeller() {
    if (widget.onMessage != null) {
      widget.onMessage!('');
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
        decoration: BoxDecoration(
          color: AppColor.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Scrollable content ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDragHandle(),
                    24.height,
                    _buildHeader(),
                    32.height,
                    Text(
                      _price,
                      style: AppTextStyle.primaryText.copyWith(
                        color: AppColor.activeColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    6.height,
                    Text(
                      _title,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (!_isChatMode) ...[
                      28.height,
                      _buildCategoryRow(),
                      28.height,
                      _buildActionButtons(),
                      28.height,
                      const Divider(
                        color: AppColor.bgSurfaceColor,
                        thickness: 1.0,
                      ),
                      28.height,
                      _buildInfoList(),
                      32.height,
                      _buildDescription(),
                      if (_listing?.sellerPhone?.isNotEmpty == true) ...[
                        32.height,
                        _buildShowNumberButton(),
                      ],
                      32.height,
                      _buildStatsList(),
                      32.height,
                      _buildReportButton(),
                      40.height,
                      _buildOtherListings(),
                      40.height,
                    ],
                  ],
                ),
              ),
            ),

            // ── Fixed bottom bar ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    24.height,
                    _buildQuickReplies(),
                    14.height,
                    const Divider(color: AppColor.bgElavated, thickness: 1.0),
                    14.height,
                    _buildInputRow(),
                    10.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(100.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          context.l10n.productDetails,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(Icons.close, color: Colors.white60, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {},
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColor.bgSurfaceColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SvgPicture.asset('assets/images/category-2.svg'),
          ),
          10.width,
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _listing == null ? _categoryLabel : _listingCategoryLabel,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white38, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _listingCategoryLabel {
    final listing = _listing!;
    if (listing.subcategoryDisplay.isNotEmpty) {
      return context.l10n.allCategoryItems(listing.subcategoryDisplay);
    }
    return listing.categoryDisplay.isNotEmpty
        ? listing.categoryDisplay
        : _categoryLabel;
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            height: 48.h,
            text: context.l10n.sellerMessage,
            onPressed: _messageSeller,
            color: Colors.transparent,
            textColor: AppColor.activeColor,
            side: const BorderSide(color: AppColor.activeColor),
          ),
        ),
        if (_listing?.sellerPhone?.isNotEmpty == true) ...[
          10.width,
          Expanded(
            child: AppButton(
              height: 48.h,
              text: context.l10n.sellerCall,
              onPressed: () {
                if (widget.onCall != null) {
                  widget.onCall!();
                } else {
                  callSeller(context, _listing?.sellerPhone);
                }
              },
              color: AppColor.activeColor,
              textColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoList() {
    final listing = _listing;
    return Column(
      children: [
        _infoRow(context.l10n.productCity, _city),
        12.height,
        _infoRow(
          context.l10n.productCategory,
          listing?.categoryDisplay.isNotEmpty == true
              ? listing!.categoryDisplay
              : _category,
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productSubcategory,
          listing?.subcategoryDisplay.isNotEmpty == true
              ? listing!.subcategoryDisplay
              : _subCategory,
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productBrand,
          listing?.brand.isNotEmpty == true ? listing!.brand : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productModel,
          listing?.model.isNotEmpty == true ? listing!.model : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productColor,
          listing?.color.isNotEmpty == true ? listing!.color : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productMemory,
          listing?.storage.isNotEmpty == true ? listing!.storage : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productSimCard,
          listing?.simCard.isNotEmpty == true ? listing!.simCard : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productDelivery,
          listing?.deliveryTypeDisplay.isNotEmpty == true
              ? listing!.deliveryTypeDisplay
              : '—',
          isLink: true,
        ),
        12.height,
        _infoRow(
          context.l10n.productCondition,
          listing?.conditionDisplay.isNotEmpty == true
              ? listing!.conditionDisplay
              : '—',
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isLink = false}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white38,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyle.primaryText.copyWith(
            color: isLink ? AppColor.activeColor : Colors.white,
            fontSize: 13.sp,
            fontWeight: isLink ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final description = _listing?.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description?.isNotEmpty == true
              ? description!
              : _listing == null
              ? context.l10n.sampleProductDescription
              : context.l10n.productDescriptionMissing,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
        8.height,
        InkWell(
          onTap: () {},
          child: Text(
            context.l10n.readMore,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.activeColor,
              fontSize: 12.sp,
              decoration: TextDecoration.underline,
              decorationColor: AppColor.activeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowNumberButton() {
    return InkWell(
      onTap: () {
        if (widget.onCall != null) {
          widget.onCall!();
        } else {
          callSeller(context, _listing?.sellerPhone);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.call, color: AppColor.activeColor, size: 18.sp),
            12.width,
            Text(
              _listing?.sellerPhone ?? context.l10n.productPhoneReveal,
              style: AppTextStyle.primaryText.copyWith(
                color: AppColor.activeColor,
                fontSize: 14.sp,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.activeColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white38, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsList() {
    final listing = _listing;
    return Column(
      children: [
        _infoRow(
          context.l10n.listingNumber,
          listing == null || listing.listingNumber?.isEmpty != false
              ? '46004795'
              : listing.listingNumber!,
        ),
        12.height,
        _infoRow(
          context.l10n.listingViewCount,
          listing == null ? '4248' : listing.viewCount.toString(),
        ),
        12.height,
        _infoRow(
          context.l10n.listingUpdated,
          listing?.updatedAt == null
              ? context.l10n.todayAt('12:14')
              : listing!.updatedAt!.toIso8601String(),
        ),
      ],
    );
  }

  Widget _buildReportButton() {
    final listingId = _listing?.id;
    final sellerId = _listing?.sellerId;
    return Row(
      children: [
        InkWell(
          onTap:
              widget.onReport ??
              (listingId == null || listingId.isEmpty ? null : _reportListing),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 18.sp),
              8.width,
              Text(
                context.l10n.report,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.red,
                  fontSize: 12.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        if (widget.onBlock != null || sellerId?.isNotEmpty == true) ...[
          const Spacer(),
          InkWell(
            onTap: widget.onBlock ?? _blockSeller,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, color: Colors.white60, size: 18.sp),
                8.width,
                Text(
                  context.l10n.block,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white60,
                    fontSize: 12.sp,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _reportListing() {
    final listingId = _listing?.id;
    if (listingId == null || listingId.isEmpty) return;
    context.goTo(ReportListingPage(listingId: listingId));
  }

  Future<void> _blockSeller() async {
    final sellerId = _listing?.sellerId;
    if (sellerId == null || sellerId.isEmpty) return;
    try {
      await context.read<EngagementRepository>().blockUser(sellerId);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  final List<Product> _listings = const [
    Product(
      id: 'sample-1',
      imageUrls: ['assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif'],
      price: 2980,
      currency: 'AZN',
      title: 'Smartfon Apple iPhone 17 Pro 256GB Cosmic Orange...',
    ),
    Product(
      id: 'sample-2',
      imageUrls: ['assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif'],
      price: 2980,
      currency: 'AZN',
      title: 'Smartfon Apple iPhone 17 Pro 256GB Cosmic Orange...',
    ),
  ];

  Widget _buildOtherListings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sellerOtherListings,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        16.height,
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.62,
          ),
          itemCount: _listings.length,
          itemBuilder: (context, index) =>
              ProductCard(product: _listings[index]),
        ),
      ],
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];

          return GestureDetector(
            onTap: () => _sendQuickReply(reply),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColor.activeColor,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                reply,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_listing?.sellerPhone?.isNotEmpty == true) ...[
          GestureDetector(
            onTap: () {
              callSeller(context, _listing?.sellerPhone);
            },
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColor.success,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.call, color: Colors.white, size: 20.sp),
            ),
          ),
          10.width,
        ],
        Expanded(
          // SpecialTextField only positions itself (see its own docs) —
          // give it a fixed height here, same as elsewhere it's used.
          child: SizedBox(
            child: SpecialTextField(
              backgroundColor: AppColor.bgElavated,
              hintText: context.l10n.askAboutProduct,
              controller: _controller,
              focusNode: _focusNode,
              floatingLabel: false,
            ),
          ),
        ),
        10.width,
        Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: _isChatMode ? AppColor.activeColor : AppColor.bgElavated,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: _send,
            child: Icon(Icons.send, color: Colors.white, size: 20.sp),
          ),
        ),
      ],
    );
  }
}

/// Opens the sheet with the padding/keyboard behavior it needs.
/// `isScrollControlled: true` is required — without it the sheet is
/// capped at half the screen height and can't grow to ride above the
/// keyboard when the text field is focused.
Future<void> showProductDetailsSheet(
  BuildContext context, {
  Product? listing,
  String? price,
  String? title,
  VoidCallback? onCall,
  ValueChanged<String>? onMessage,
  ValueChanged<String>? onSend,
  VoidCallback? onReport,
  VoidCallback? onBlock,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailsSheet(
      listing: listing,
      price:
          price ??
          (listing == null
              ? CurrencyFormatter.formatPrice(2890.24, fallbackCurrencyCode)
              : CurrencyFormatter.formatPrice(listing.price, listing.currency)),
      title:
          title ??
          listing?.title ??
          'Smartfon Apple iPhone 17 Pro 256GB Cosmic Orange MG7L4LL/A',
      onCall: onCall,
      onMessage: onMessage,
      onSend: onSend,
      onReport: onReport,
      onBlock: onBlock,
    ),
  );
}

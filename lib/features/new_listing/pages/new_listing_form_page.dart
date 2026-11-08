import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/features/new_listing/widgets/listing_basic_info_section.dart';
import 'package:vidsell/features/new_listing/widgets/listing_contact_section.dart';
import 'package:vidsell/features/new_listing/widgets/listing_media_section.dart';
import 'package:vidsell/features/new_listing/widgets/listing_price_section.dart';
import 'package:vidsell/features/new_listing/widgets/listing_form_components.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/enums/seller_type.dart';
export 'package:vidsell/features/new_listing/models/listing_draft.dart';

class NewListingFormPage extends StatefulWidget {
  const NewListingFormPage({
    super.key,
    required this.category,
    required this.subcategory,
    required this.title,
    this.repository,
    this.cityRepository,
  });

  final CategoryItem category;
  final Subcategory subcategory;
  final String title;
  final ListingRepository? repository;
  final CityRepository? cityRepository;

  @override
  State<NewListingFormPage> createState() => _NewListingFormPageState();
}

class _NewListingFormPageState extends State<NewListingFormPage> {
  late final ListingRepository _listingRepository;
  late final CityRepository _cityRepository;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ListingCondition? _condition;
  DeliveryOption? _delivery;
  ContactMethod _contactMethod = ContactMethod.callsAndMessages;
  SellerType _sellerType = SellerType.individual;
  bool _isSubmitting = false;
  final List<String> _videoUrls = [];
  final List<Duration> _videoDurations = [];
  final List<String> _videoCoverUrls = [];
  final List<String> _imageUrls = [];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _titleController.dispose();
    _cityController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _listingRepository = widget.repository ?? context.read<ListingRepository>();
    _cityRepository = widget.cityRepository ?? context.read<CityRepository>();
  }

  void _resetForm() {
    setState(() {
      _brandController.clear();
      _modelController.clear();
      _priceController.clear();
      _titleController.clear();
      _cityController.clear();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _descriptionController.clear();
      _condition = null;
      _delivery = null;
      _contactMethod = ContactMethod.callsAndMessages;
      _sellerType = SellerType.individual;
      _videoUrls.clear();
      _videoDurations.clear();
      _videoCoverUrls.clear();
      _imageUrls.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(widget.title),
            14.height,
            const Divider(color: AppColor.bgSecondary, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    _buildCategoryField(),
                    12.height,
                    const ListingSectionHeader('Seller type'),
                    ListingRadioRow(
                      label: 'Individual',
                      selected: _sellerType == SellerType.individual,
                      onTap: () =>
                          setState(() => _sellerType = SellerType.individual),
                    ),
                    ListingRadioRow(
                      label: 'Store',
                      selected: _sellerType == SellerType.store,
                      onTap: () =>
                          setState(() => _sellerType = SellerType.store),
                    ),
                    12.height,
                    ListingBasicInfoSection(
                      brandController: _brandController,
                      modelController: _modelController,
                    ),
                    12.height,
                    ListingPriceSection(priceController: _priceController),
                    12.height,
                    _buildCityField(),
                    24.height,
                    ListingSectionHeader(context.l10n.listingCondition),
                    ListingRadioRow(
                      label: context.l10n.newCondition,
                      selected: _condition == ListingCondition.newItem,
                      onTap: () =>
                          setState(() => _condition = ListingCondition.newItem),
                    ),
                    ListingRadioRow(
                      label: context.l10n.usedCondition,
                      selected: _condition == ListingCondition.used,
                      onTap: () =>
                          setState(() => _condition = ListingCondition.used),
                    ),
                    24.height,
                    ListingSectionHeader(context.l10n.listingDelivery),
                    ListingRadioRow(
                      label: context.l10n.freeDelivery,
                      selected: _delivery == DeliveryOption.free,
                      onTap: () =>
                          setState(() => _delivery = DeliveryOption.free),
                    ),
                    ListingRadioRow(
                      label: context.l10n.deliveryToRegions,
                      selected: _delivery == DeliveryOption.paid,
                      onTap: () =>
                          setState(() => _delivery = DeliveryOption.paid),
                    ),
                    ListingRadioRow(
                      label: context.l10n.pickupAtAddress,
                      selected: _delivery == DeliveryOption.none,
                      onTap: () =>
                          setState(() => _delivery = DeliveryOption.none),
                    ),
                    24.height,
                    ListingTextField(
                      controller: _titleController,
                      label: context.l10n.listingTitle,
                    ),
                    24.height,
                    ListingSectionHeader(context.l10n.listingContent),
                    12.height,
                    _buildDescriptionField(),
                    24.height,
                    ListingContactSection(
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      contactMethod: _contactMethod,
                      onContactMethodChanged: (method) =>
                          setState(() => _contactMethod = method),
                    ),
                    24.height,
                    ListingMediaSection(
                      imagePaths: _imageUrls,
                      videoPaths: _videoUrls,
                      videoDurations: _videoDurations,
                      onImageAdded: (path) =>
                          setState(() => _imageUrls.add(path)),
                      onImageRemoved: (index) =>
                          setState(() => _imageUrls.removeAt(index)),
                      onVideoAdded: (path, duration) => setState(() {
                        _videoUrls.add(path);
                        _videoDurations.add(duration);
                        _videoCoverUrls.add('');
                      }),
                      onVideoRemoved: (index) => setState(() {
                        final coverPath = _videoCoverUrls[index];
                        if (coverPath.isNotEmpty) {
                          _imageUrls.remove(coverPath);
                        }
                        _videoUrls.removeAt(index);
                        _videoDurations.removeAt(index);
                        _videoCoverUrls.removeAt(index);
                      }),
                      onVideoCoverChanged: (index, path) {
                        if (index >= _videoCoverUrls.length) return;
                        setState(() {
                          final previousPath = _videoCoverUrls[index];
                          _videoCoverUrls[index] = path;
                          if (previousPath.isEmpty) {
                            _imageUrls.add(path);
                          } else {
                            final imageIndex = _imageUrls.indexOf(previousPath);
                            if (imageIndex >= 0) _imageUrls[imageIndex] = path;
                          }
                        });
                      },
                    ),
                    24.height,
                    _buildFinishButton(),
                    12.height,
                    Text(
                      AppLocalizations.of(context)!.listingRulesText,
                      style: AppTextStyle.mutedText.copyWith(
                        fontSize: 11.sp,
                        color: AppColor.tertiaryTextColor,
                      ),
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          IconButton(
            onPressed: context.goBack,
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor.tertiaryTextColor,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: 80.w,
            child: TextButton(
              onPressed: _resetForm,
              child: Text(
                context.l10n.reset,
                textAlign: TextAlign.right,
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.activeColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: listingFieldDecoration,
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            padding: EdgeInsets.all(5.w),
            child: widget.category.iconPath.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.category.iconPath,
                    fit: BoxFit.contain,
                  )
                : Image.asset(widget.category.iconPath, fit: BoxFit.contain),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.category,
                  style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
                ),
                2.height,
                Text(
                  '${widget.category.localizedLabel(context.l10n)}/'
                  '${widget.subcategory.localizedLabel(context.l10n)}',
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: context.goBack,
            icon: Icon(
              Icons.close,
              color: AppColor.tertiaryTextColor,
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: listingFieldDecoration,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              onChanged: (_) => setState(() {}), // shows/hides the X button
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: listingInputDecoration(
                label: context.l10n.searchCity,
              ),
            ),
          ),
          if (_cityController.text.isNotEmpty)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() => _cityController.clear()),
              icon: Icon(
                Icons.close,
                color: AppColor.tertiaryTextColor,
                size: 18.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: listingFieldDecoration,
      child: TextField(
        controller: _descriptionController,
        minLines: 4,
        maxLines: 4,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: listingInputDecoration(
          hint: context.l10n.listingDescriptionHint,
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.activeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: _isSubmitting ? null : _submitListing,
        child: Text(
          _isSubmitting
              ? AppLocalizations.of(context)!.submitting
              : AppLocalizations.of(context)!.createListing,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _submitListing() async {
    final price = double.tryParse(_priceController.text.trim());
    final hasMedia = _imageUrls.isNotEmpty || _videoUrls.isNotEmpty;
    final l10n = context.l10n;
    final missing = <String>[
      if (_modelController.text.trim().isEmpty) l10n.listingFieldModel,
      if (price == null || price <= 0) l10n.listingFieldPrice,
      if (_cityController.text.trim().isEmpty) l10n.listingFieldCity,
      if (_condition == null) l10n.listingFieldCondition,
      if (_delivery == null) l10n.listingFieldDelivery,
      if (_titleController.text.trim().isEmpty) l10n.listingFieldTitle,
      if (_descriptionController.text.trim().isEmpty)
        l10n.listingFieldDescription,
      if (_nameController.text.trim().isEmpty) l10n.listingFieldName,
      if (_emailController.text.trim().isEmpty) l10n.listingFieldEmail,
      if (_phoneController.text.trim().isEmpty) l10n.listingFieldPhone,
      if (!hasMedia) l10n.listingFieldMedia,
    ];
    if (missing.isNotEmpty) {
      _showMessage(l10n.fillListingFields(missing.join(', ')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final selectedCity = await _resolveCity(_cityController.text, l10n);
      if (!mounted) return;
      if (selectedCity == null) {
        _showMessage(l10n.listingCityNotFound);
        return;
      }
      final draft = ListingDraft(
        categoryId: widget.category.id,
        categoryName: widget.category.localizedLabel(l10n),
        subcategoryId: widget.subcategory.id,
        subcategoryName: widget.subcategory.localizedLabel(l10n),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        price: price!,
        city: selectedCity.name,
        cityId: selectedCity.id,
        condition: _condition!,
        delivery: _delivery!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        sellerName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        contactMethod: _contactMethod.name,
        imagePaths: List.unmodifiable(_imageUrls),
        videoPaths: List.unmodifiable(_videoUrls),
        sellerType: _sellerType,
        videoCoverPaths: List.unmodifiable(_videoCoverUrls),
      );
      final createdListing = await _listingRepository.createListing(draft);
      if (!mounted) return;
      final previewImage = draft.imagePaths.isNotEmpty
          ? draft.imagePaths.first
          : draft.videoPaths.isNotEmpty
          ? draft.videoPaths.first
          : '';
      await context.goToListingPromotion(
        title: draft.title,
        price: CurrencyFormatter.formatPrice(
          draft.price,
          draft.currency,
          decimalDigits: 2,
        ),
        city: draft.city,
        category: draft.categoryName,
        subcategory: draft.subcategoryName,
        image: previewImage,
        listingId: createdListing.id,
        status: createdListing.status.apiValue,
      );
    } catch (error) {
      if (mounted) {
        final message = error is StateError && error.message == 'missing_media'
            ? l10n.listingMediaRequired
            : l10n.genericError;
        _showMessage(message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<City?> _resolveCity(String input, AppLocalizations l10n) async {
    final normalizedInput = _normalizeCityName(input);
    final cities = await _cityRepository.fetchCities();
    for (final city in cities) {
      if (_normalizeCityName(city.name) == normalizedInput ||
          _normalizeCityName(city.localizedName(l10n)) == normalizedInput) {
        return city;
      }
    }
    return null;
  }

  String _normalizeCityName(String value) =>
      value.trim().toLowerCase().replaceAll('ı', 'i').replaceAll('\u0307', '');

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

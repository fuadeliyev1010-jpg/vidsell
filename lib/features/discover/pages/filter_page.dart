import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/models/listing_filter.dart';
import 'package:vidsell/features/discover/pages/category_picker_page.dart';
import 'package:vidsell/features/discover/pages/city_picker_page.dart';
import 'package:vidsell/models/enums/seller_type.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class FilterPage extends StatefulWidget {
  final CategoryItem? category;
  const FilterPage({super.key, this.category});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubcategoryId;
  String? _selectedSubcategory;
  String? _selectedCityId;
  String? _selectedCity;
  SortOption _selectedSort = SortOption.recommended;
  SellerType? _selectedSellerType;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.category?.id;
    _selectedCategoryName = widget.category?.label;
  }

  void _resetFilters() {
    setState(() {
      _minController.clear();
      _maxController.clear();
      _selectedCategoryId = widget.category?.id;
      _selectedCategoryName = widget.category?.label;
      _selectedSubcategoryId = null;
      _selectedSubcategory = null;
      _selectedCityId = null;
      _selectedCity = null;
      _selectedSort = SortOption.recommended;
      _selectedSellerType = null;
    });
  }

  Future<void> _pickCity() async {
    final selected = await context.goTo<City>(const CityPickerPage());
    if (selected != null && mounted) {
      setState(() {
        _selectedCityId = selected.id;
        _selectedCity = selected.name;
      });
    }
  }

  void _applyFilters() {
    // Validate price inputs
    if (_minController.text.isNotEmpty && _maxController.text.isNotEmpty) {
      final minPrice = double.tryParse(_minController.text);
      final maxPrice = double.tryParse(_maxController.text);

      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.minimumPriceError)));
        return;
      }
    }

    final minPrice = double.tryParse(_minController.text.replaceAll(',', '.'));
    final maxPrice = double.tryParse(_maxController.text.replaceAll(',', '.'));
    context.goBack(
      ListingFilter(
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        subcategoryId: _selectedSubcategoryId,
        subcategoryName: _selectedSubcategory,
        cityId: _selectedCityId,
        cityName: _selectedCity,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: _selectedSort,
        sellerType: _selectedSellerType,
      ),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  12.height,
                  _buildSectionTitle(context.l10n.category),
                  10.height,
                  _buildCategoryRow(),
                  20.height,
                  _buildSectionTitle(context.l10n.price),
                  10.height,
                  _buildPriceRow(),
                  12.height,
                  _buildCityRow(),
                  20.height,
                  _buildSectionTitle('Seller type'),
                  10.height,
                  ...SellerType.values.map(_buildSellerTypeTile),
                  20.height,
                  _buildSectionTitle(context.l10n.sort),
                  10.height,
                  ...SortOption.values.map(_buildSortTile),
                  24.height,
                ],
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          Expanded(
            child: Text(
              context.l10n.filters,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: _resetFilters,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              child: Text(
                context.l10n.reset,
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.activeColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () async {
        final result = await context.goTo<Map<String, String>>(
          const CategoryPickerPage(),
        );
        if (result != null && mounted) {
          setState(() {
            _selectedCategoryId = result['categoryId'];
            _selectedCategoryName = result['categoryName'];
            _selectedSubcategoryId = result['id'];
            _selectedSubcategory = result['name'];
          });
        }
      },
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: AppColor.activeColor,
              size: 18.sp,
            ),
            10.width,
            Expanded(
              child: Text(
                _selectedSubcategory ??
                    _selectedCategoryName ??
                    context.l10n.category,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.tertiaryTextColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceField(_minController, context.l10n.minimumPrice),
        ),
        10.width,
        Expanded(
          child: _buildPriceField(_maxController, context.l10n.maximumPrice),
        ),
      ],
    );
  }

  Widget _buildPriceField(TextEditingController controller, String hint) {
    return SizedBox(
      height: 48.h,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.primaryText.copyWith(
            color: AppColor.tertiaryTextColor,
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
          filled: true,
          fillColor: AppColor.bgSurfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCityRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: _pickCity,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCity ?? context.l10n.searchCity,
                style: AppTextStyle.primaryText.copyWith(
                  color: _selectedCity == null
                      ? AppColor.tertiaryTextColor
                      : Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.tertiaryTextColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(SortOption option) {
    final isSelected = _selectedSort == option;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => setState(() => _selectedSort = option),
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColor.bgSurfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(color: AppColor.activeColor, width: 1.w)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  switch (option) {
                    SortOption.recommended => context.l10n.sortRecommended,
                    SortOption.lowestPrice => context.l10n.sortLowestPrice,
                    SortOption.highestPrice => context.l10n.sortHighestPrice,
                    SortOption.newest => context.l10n.sortNewestListings,
                  },
                  style: AppTextStyle.primaryText.copyWith(
                    color: isSelected ? AppColor.activeColor : Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? AppColor.activeColor
                    : AppColor.tertiaryTextColor,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerTypeTile(SellerType type) {
    final selected = _selectedSellerType == type;
    return InkWell(
      onTap: () => setState(() {
        _selectedSellerType = selected ? null : type;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColor.activeColor : Colors.grey.shade500,
            ),
            10.width,
            Text(
              type == SellerType.individual ? 'Individual' : 'Store',
              style: AppTextStyle.primaryText.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.activeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 0,
          ),
          child: Text(
            context.l10n.showListings,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.primaryColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

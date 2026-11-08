import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

enum SortOption { recommended, lowestPrice, highestPrice, newest }

class FilterCategoryPage extends StatefulWidget {
  const FilterCategoryPage({super.key, this.category});

  /// Category selected on Discover before opening the filters — used to
  /// pre-fill the "Kategori" row so it matches what the user was
  /// already browsing.
  final CategoryItem? category;

  @override
  State<FilterCategoryPage> createState() => _FilterCategoryPageState();
}

class _FilterCategoryPageState extends State<FilterCategoryPage> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;
  SortOption _selectedSort = SortOption.recommended;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category?.label;
  }

  void _resetFilters() {
    setState(() {
      _minController.clear();
      _maxController.clear();
      _selectedCategory = null;
      _selectedCity = null;
      _selectedSort = SortOption.recommended;
    });
  }

  Future<void> _pickCategory() async {
    // TODO: navigate to the real category picker and set the result.
  }

  Future<void> _pickCity() async {
    // TODO: navigate to the real city picker and set the result.
  }

  void _applyFilters() {
    // TODO: pass the selected filters back to the caller / repository.
    context.goBack({
      'category': _selectedCategory,
      'minPrice': _minController.text,
      'maxPrice': _maxController.text,
      'city': _selectedCity,
      'sort': _selectedSort,
    });
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
      onTap: _pickCategory,
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
                _selectedCategory ?? context.l10n.category,
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
        keyboardType: TextInputType.number,
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

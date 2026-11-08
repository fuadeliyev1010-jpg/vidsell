import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/new_listing/pages/category_details_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class NewListingPage extends StatefulWidget {
  const NewListingPage({super.key});

  @override
  State<NewListingPage> createState() => _NewListingPageState();
}

class _NewListingPageState extends State<NewListingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryItem> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredCategories() {
    final categories = CategoryItem.categories
        .where((category) => category.id != 'catalog')
        .toList();

    if (_searchController.text.isEmpty) {
      _filteredCategories = categories;
    } else {
      final query = _searchController.text.toLowerCase();
      _filteredCategories = categories
          .where(
            (category) => category
                .localizedLabel(context.l10n)
                .toLowerCase()
                .contains(query),
          )
          .toList();
    }
  }

  void _navigateToCategoryDetails(CategoryItem category) {
    context.goTo(
      CategoryDetailsPage(category: category, title: context.l10n.newListing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            14.height,
            const Divider(color: AppColor.bgSecondary, thickness: 1),
            14.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSearchBar(),
            ),
            24.height,
            Expanded(
              child: _filteredCategories.isEmpty
                  ? _buildEmptyState()
                  : _buildCategoryList(_filteredCategories),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 1),
    );
  }

  Widget _buildAppBar() {
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
              context.l10n.newListing,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 37.h,
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {
            _updateFilteredCategories();
          });
        },
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(9.0.w),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                AppColor.tertiaryTextColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          hintText: context.l10n.searchCategory,
          hintStyle: AppTextStyle.primaryText.copyWith(
            color: AppColor.tertiaryTextColor,
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColor.bgSurfaceColor,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryItem> categories) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryRow(categories[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48.sp,
            color: AppColor.tertiaryTextColor,
          ),
          16.height,
          Text(
            context.l10n.noCategoryFound,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.tertiaryTextColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryItem category) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () => _navigateToCategoryDetails(category),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCategoryIcon(category),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.localizedLabel(context.l10n),
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      2.height,
                      Text(
                        context.l10n.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.mutedText.copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            14.height,
            Padding(
              padding: EdgeInsets.only(left: 52.w),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xff252934),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CategoryItem category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: AppColor.bgSurfaceColor,
      ),
      width: 38.w,
      height: 38.w,
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: category.iconPath.endsWith('.svg')
            ? SvgPicture.asset(
                category.iconPath,
                width: 26.w,
                height: 26.w,
                fit: BoxFit.contain,
              )
            : Image.asset(
                category.iconPath,
                width: 26.w,
                height: 26.w,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}

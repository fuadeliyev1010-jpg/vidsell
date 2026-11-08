import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/pages/subcategory_list_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class CategoryPickerPage extends StatefulWidget {
  const CategoryPickerPage({super.key});

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<CategoryItem> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _categoryList;
    _searchController.addListener(_filterCategories);
  }

  List<CategoryItem> get _categoryList => CategoryItem.categories
      .where((category) => category.id != 'catalog')
      .toList(growable: false);

  void _filterCategories() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _categories = _categoryList
          .where(
            (category) => category
                .localizedLabel(context.l10n)
                .toLowerCase()
                .contains(query),
          )
          .toList(growable: false);
    });
  }

  Future<void> _openSubcategories(CategoryItem category) async {
    final selected = await context.goTo<Map<String, String>>(
      SubcategoryListPage(
        category: category,
        showBottomNavigation: false,
        returnSubcategory: true,
      ),
    );
    if (selected != null && mounted) {
      context.goBack(selected);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filterCategories)
      ..dispose();
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: TextField(
                controller: _searchController,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.searchCategory,
                  hintStyle: AppTextStyle.primaryText.copyWith(
                    color: AppColor.tertiaryTextColor,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.tertiaryTextColor,
                    size: 17.sp,
                  ),
                  filled: true,
                  fillColor: AppColor.bgSurfaceColor,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _categories.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noCategoryFound,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.tertiaryTextColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1.h,
                      ),
                      itemBuilder: (context, index) =>
                          _buildCategoryTile(_categories[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: context.goBack,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColor.tertiaryTextColor,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.category,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(CategoryItem category) {
    return InkWell(
      onTap: () => _openSubcategories(category),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: category.iconPath.endsWith('.svg')
                  ? SvgPicture.asset(category.iconPath)
                  : Image.asset(
                      category.iconPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.category_outlined,
                        color: AppColor.tertiaryTextColor,
                        size: 20.sp,
                      ),
                    ),
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.localizedLabel(context.l10n),
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                2.height,
                Text(
                  context.l10n.category,
                  style: AppTextStyle.primaryText.copyWith(
                    color: AppColor.tertiaryTextColor,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

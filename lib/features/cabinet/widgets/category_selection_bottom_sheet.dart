import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class CategorySelectionBottomSheet extends StatefulWidget {
  final Function(String selectedCategory) onCategorySelected;

  const CategorySelectionBottomSheet({
    super.key,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  CategoryItem? _selectedParentCategory;

  final Map<String, List<String>> _subCategories = {
    'electronics': ['Telefonlar', 'Kompüterlər'],
  };

  @override
  Widget build(BuildContext context) {
    final categories = CategoryItem.categories
        .where((cat) => cat.id != 'catalog')
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          16.height,
          _buildHeader(),
          16.height,
          Expanded(
            child: _selectedParentCategory == null
                ? _buildMainCategoryList(categories)
                : _buildSubCategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_selectedParentCategory != null) {
                setState(() {
                  _selectedParentCategory = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
          ),
          Expanded(
            child: Text(
              context.l10n.categories,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildMainCategoryList(List<CategoryItem> categories) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: categories.length,
      separatorBuilder: (context, index) =>
          Divider(color: const Color(0xFF232C3A), height: 1.h),
      itemBuilder: (context, index) {
        final category = categories[index];
        final subTitles = [
          context.l10n.categoryPhones,
          context.l10n.subcategoryComputers,
        ].join(', ');

        return InkWell(
          onTap: () {
            setState(() {
              _selectedParentCategory = category;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColor.bgSurfaceColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.all(6.r),
                  child: Image.asset(
                    category.iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.devices, color: Colors.white, size: 20.sp),
                  ),
                ),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      2.height,
                      Text(
                        subTitles,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryList() {
    final subCats =
        _subCategories[_selectedParentCategory!.id] ??
        ['Telefonlar', 'Kompüterlər'];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: subCats.length,
      separatorBuilder: (context, index) =>
          Divider(color: const Color(0xFF232C3A), height: 1.h),
      itemBuilder: (context, index) {
        final subCategory = subCats[index];
        return InkWell(
          onTap: () {
            widget.onCategorySelected(subCategory);
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              subCategory == 'Telefonlar'
                  ? context.l10n.categoryPhones
                  : context.l10n.subcategoryComputers,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}

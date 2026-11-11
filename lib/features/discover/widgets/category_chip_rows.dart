import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

const categoryBrandChips = [
  'Apple iPhone',
  'Samsung',
  'Xiaomi',
  'Honor',
  'Huawei',
];

bool categoryShowsBrandChips(String? categoryId) {
  final normalized = categoryId?.toUpperCase();
  return normalized == 'ELECTRONICS' ||
      CategoryItem.categories.any(
        (category) =>
            category.apiCode == 'ELECTRONICS' && category.id == categoryId,
      );
}

bool shouldShowCategoryChipRow(List<Subcategory> subcategories) =>
    subcategories.isNotEmpty;

class CategoryChipRows extends StatelessWidget {
  const CategoryChipRows({
    required this.categoryId,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.selectedBrand,
    required this.onSubcategorySelected,
    required this.onBrandSelected,
    super.key,
  });

  final String? categoryId;
  final List<Subcategory> subcategories;
  final String? selectedSubcategoryId;
  final String selectedBrand;
  final ValueChanged<String?> onSubcategorySelected;
  final ValueChanged<String> onBrandSelected;

  @override
  Widget build(BuildContext context) {
    if (!shouldShowCategoryChipRow(subcategories)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 38.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length,
            separatorBuilder: (_, _) => 8.width,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              final isSelected = selectedSubcategoryId == subcategory.id;
              return _chip(
                context,
                label: subcategory.label,
                selected: isSelected,
                onTap: () =>
                    onSubcategorySelected(isSelected ? null : subcategory.id),
              );
            },
          ),
        ),
        if (categoryShowsBrandChips(categoryId)) ...[
          8.height,
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: categoryBrandChips.length + 1,
              separatorBuilder: (_, _) => 8.width,
              itemBuilder: (context, index) {
                final brand = index == categoryBrandChips.length
                    ? 'all'
                    : categoryBrandChips[index];
                return _chip(
                  context,
                  label: brand == 'all' ? context.l10n.all : brand,
                  selected: selectedBrand == brand,
                  onTap: () => onBrandSelected(brand),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? AppColor.bgSurfaceColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColor.bgSurfaceColor),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

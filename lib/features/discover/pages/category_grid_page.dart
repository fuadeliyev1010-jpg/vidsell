import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/pages/subcategory_list_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class CategoryGridPage extends StatelessWidget {
  const CategoryGridPage({super.key, required this.categories});

  /// Subcategories to show in the grid — the "Katalog" entry itself
  /// should be excluded by the caller before passing this in.
  final List<CategoryItem> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryTile(context, category);
                },
              ),
            ),
            const BottomNavigation(currentNavIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              context.l10n.catalog,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Balances the back button so the title stays centered.
          SizedBox(width: 30.w),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryItem category) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () async {
        final result = await context.goTo<CategoryItem>(
          SubcategoryListPage(category: category),
        );
        if (result != null && context.mounted) {
          context.goBack(result);
        }
      },
      child: Container(
        height: 128.h,
        width: 108.w,
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        // Column instead of Stack: label sits on its own line at the
        // top, then the icon is a FIXED 90x90 box (not stretched to
        // fill the tile), centered in the remaining space — this is
        // what removes the overflow while keeping the icon's own
        // size/position exactly as designed.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 30,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                category.localizedLabel(context.l10n),
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: category.secondIconPath!.endsWith('.svg')
                    ? SvgPicture.asset(category.secondIconPath!)
                    : Image.asset(category.secondIconPath!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

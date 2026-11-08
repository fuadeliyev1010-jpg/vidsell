import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/discover/bloc/subcategory_bloc.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/pages/category_results_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SubcategoryListPage extends StatelessWidget {
  const SubcategoryListPage({
    super.key,
    required this.category,
    this.showBottomNavigation = true,
    this.returnSubcategory = false,
  });

  final CategoryItem category;
  final bool showBottomNavigation;
  final bool returnSubcategory;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SubcategoryBloc()..add(SubcategoriesRequested(category.id)),
      child: BlocBuilder<SubcategoryBloc, SubcategoryState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColor.primaryColor,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildContent(context, state)),
                ],
              ),
            ),
            bottomNavigationBar: showBottomNavigation
                ? const BottomNavigation(currentNavIndex: 1)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubcategoryState state) {
    if (state.status == SubcategoryStatus.loading ||
        state.status == SubcategoryStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.status == SubcategoryStatus.failure) {
      return Center(
        child: Text(
          context.l10n.loadFailed,
          textAlign: TextAlign.center,
          style: AppTextStyle.primaryText.copyWith(color: Colors.white),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        ...state.subcategories.map(
          (subcategory) => _buildSubcategoryTile(context, subcategory),
        ),
        16.height,
        _buildShowAllButton(context),
        16.height,
      ],
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
              category.localizedLabel(context.l10n),
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

  Widget _buildSubcategoryTile(BuildContext context, Subcategory subcategory) {
    return InkWell(
      onTap: () {
        if (returnSubcategory) {
          context.goBack({
            'id': subcategory.id,
            'name': subcategory.label,
            'categoryId': subcategory.categoryId,
            'categoryName': category.label,
          });
        } else {
          context.goTo(
            CategoryResultsPage(
              title: subcategory.localizedLabel(context.l10n),
              categoryId: subcategory.categoryId,
              subcategoryId: subcategory.id,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.category_outlined,
                color: AppColor.tertiaryTextColor,
                size: 18.sp,
              ),
            ),
            12.width,
            Expanded(
              child: Text(
                subcategory.localizedLabel(context.l10n),
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.tertiaryTextColor,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAllButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: () {
        if (returnSubcategory) {
          context.goBack({
            'id': category.id,
            'name': category.label,
            'categoryId': category.id,
            'categoryName': category.label,
          });
        } else {
          context.goTo(
            CategoryResultsPage(
              title: category.localizedLabel(context.l10n),
              categoryId: category.id,
            ),
          );
        }
      },
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, color: Colors.white, size: 16.sp),
            8.width,
            Text(
              context.l10n.allListings,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

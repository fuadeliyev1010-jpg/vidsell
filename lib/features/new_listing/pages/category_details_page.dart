import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';
import 'package:vidsell/features/new_listing/pages/new_listing_form_page.dart';
import 'package:vidsell/features/new_listing/widgets/sub_category_item_tile.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class CategoryDetailsPage extends StatefulWidget {
  const CategoryDetailsPage({
    super.key,
    required this.category,
    required this.title,
  });

  final CategoryItem category;
  final String title;

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  late final SubcategoryRepository _subcategoryRepository;
  List<Subcategory> subCategories = const [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _subcategoryRepository = context.read<SubcategoryRepository>();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final subcategories = await _subcategoryRepository.fetchForCategory(
        widget.category.id,
      );
      if (!mounted) return;
      setState(() {
        subCategories = subcategories;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        final rawBody = error is ApiException
            ? error.rawResponseBody
            : 'unavailable; see repository diagnostics';
        debugPrint(
          '[CategoryDetails] Subcategory load failed: $error\n'
          '$stackTrace\n'
          'Raw response body: $rawBody',
        );
      }
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToNewListingForm(Subcategory? subCategory) {
    context.goTo(
      NewListingFormPage(
        category: widget.category,
        subcategory: subCategory,
        title: widget.title,
      ),
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
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.activeColor,
                      ),
                    )
                  : _loadError != null
                  ? _buildErrorState()
                  : subCategories.isEmpty
                  ? _buildEmptyState()
                  : _buildSubCategoryList(),
            ),
            if (!_isLoading && _loadError == null && subCategories.isEmpty)
              _buildContinueButton()
            else
              _buildAllListingsButton(),
          ],
        ),
      ),
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
              widget.category.localizedLabel(context.l10n),
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

  Widget _buildSubCategoryList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        return _buildSubCategoryRow(subCategories[index]);
      },
    );
  }

  Widget _buildSubCategoryRow(Subcategory subCategory) {
    return SubCategoryItemTile(
      subCategory: subCategory,
      onTap: () => _navigateToNewListingForm(subCategory),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.loadFailed,
            textAlign: TextAlign.center,
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.tertiaryTextColor,
              fontSize: 14.sp,
            ),
          ),
          12.height,
          TextButton.icon(
            onPressed: () => _loadSubCategories(showLoading: true),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 48.sp,
            color: AppColor.tertiaryTextColor,
          ),
          16.height,
          Text(
            'Bu kategoride alt kategori yok',
            style: AppTextStyle.primaryText.copyWith(
              color: AppColor.tertiaryTextColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.primaryColor,
        border: Border(top: BorderSide(color: AppColor.bgSecondary, width: 1)),
      ),
      padding: EdgeInsets.all(16.w),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _navigateToNewListingForm(null),
            child: const Text('Devam et'),
          ),
        ),
      ),
    );
  }

  Widget _buildAllListingsButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.primaryColor,
        border: Border(top: BorderSide(color: AppColor.bgSecondary, width: 1)),
      ),
      padding: EdgeInsets.all(16.w),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.showCategoryListings(
                      widget.category.localizedLabel(context.l10n),
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  8.width,
                  Text(
                    context.l10n.allListings,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stores = [
      ('Evım Market', context.l10n.mockStoreDescriptionHome),
      ('Texno Dünya', context.l10n.mockStoreDescriptionTech),
      ('Moda Geyim', context.l10n.mockStoreDescriptionFashion),
      ('Auto Plus', context.l10n.mockStoreDescriptionAuto),
      ('Bağçam', context.l10n.mockStoreDescriptionGarden),
      ('Usta Alət', context.l10n.mockStoreDescriptionTools),
      ('Körpə Aləmi', context.l10n.mockStoreDescriptionBaby),
      ('Kitab Evi', context.l10n.mockStoreDescriptionBooks),
    ];
    final filteredStores = stores
        .where((store) => store.$1.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: context.goBack,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColor.secondaryTextColor,
                        size: 17.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.stores,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 25.w),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: AppTextStyle.primaryText.copyWith(fontSize: 11.sp),
                decoration: InputDecoration(
                  hintText: context.l10n.storeSearch,
                  hintStyle: AppTextStyle.primaryText.copyWith(
                    color: AppColor.mutedColor,
                    fontSize: 11.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.mutedColor,
                    size: 18.sp,
                  ),
                  filled: true,
                  fillColor: AppColor.bgSurfaceColor,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            8.height,
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: filteredStores.length,
                itemBuilder: (context, index) {
                  final store = filteredStores[index];
                  return _buildStoreTile(store.$1, store.$2);
                },
              ),
            ),
            const BottomNavigation(currentNavIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreTile(String name, String description) {
    return Container(
      height: 61.h,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.bgSurfaceColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17.r,
            backgroundColor: AppColor.bgElavated,
            child: Icon(
              Icons.storefront_outlined,
              color: AppColor.secondaryTextColor,
              size: 18.sp,
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyle.primaryText.copyWith(fontSize: 11.sp),
                ),
                2.height,
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.primaryText.copyWith(
                    color: AppColor.secondaryTextColor,
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
          8.width,
          Container(
            width: 27.w,
            height: 27.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.success),
            ),
            child: Icon(Icons.phone, color: AppColor.success, size: 14.sp),
          ),
        ],
      ),
    );
  }
}

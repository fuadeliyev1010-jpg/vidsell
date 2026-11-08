import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SubCategoryItemTile extends StatelessWidget {
  const SubCategoryItemTile({
    super.key,
    required this.subCategory,
    required this.onTap,
  });

  final Subcategory subCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    subCategory.localizedLabel(context.l10n),
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
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
            12.height,
            const Divider(height: 1, thickness: 1, color: Color(0xff252934)),
          ],
        ),
      ),
    );
  }
}

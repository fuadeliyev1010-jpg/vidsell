import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

class CabinAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CabinAppbar({
    super.key,
    required this.title,
    this.appBarHeight = 88,
    this.spaceBetweenTitleAndDivider = 24,
  });
  final String title;
  final double appBarHeight;
  final double spaceBetweenTitleAndDivider;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: appBarHeight.h,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColor.mutedColor,
                  size: 24.sp,
                ),
                onPressed: context.goBack,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.primaryText.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: kMinInteractiveDimension),
            ],
          ),
          spaceBetweenTitleAndDivider.height,
          Divider(color: const Color(0xFF232C3A), height: 1.h, thickness: 1.h),
        ],
      ),
    );
  }
}

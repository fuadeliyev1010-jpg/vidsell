import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class SortSelectionBottomSheet extends StatefulWidget {
  final String? selectedSort;
  final Function(String selectedSort) onSortSelected;

  const SortSelectionBottomSheet({
    super.key,
    this.selectedSort,
    required this.onSortSelected,
  });

  @override
  State<SortSelectionBottomSheet> createState() =>
      _SortSelectionBottomSheetState();
}

class _SortSelectionBottomSheetState extends State<SortSelectionBottomSheet> {
  late String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      ('price_asc', context.l10n.sortPriceLowest),
      ('price_desc', context.l10n.sortPriceHighest),
      ('newest', context.l10n.sortNewest),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            12.height,
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            16.height,
            _buildHeader(),
            16.height,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: sortOptions.length,
              separatorBuilder: (context, index) => 12.height,
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                final isSelected = _currentSelection == option.$1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentSelection = option.$1;
                    });
                    widget.onSortSelected(option.$1);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.bgSurfaceColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.activeColor
                            : const Color(0xFF293240),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.$2,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Container(
                          width: 20.r,
                          height: 20.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.activeColor
                                  : Colors.grey.shade600,
                              width: isSelected ? 6.r : 1.5.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            24.height,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.sort,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.grey.shade400, size: 22.sp),
          ),
        ],
      ),
    );
  }
}

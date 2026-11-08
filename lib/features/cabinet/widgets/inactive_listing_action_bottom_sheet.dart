import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class InactiveListingActionBottomSheet extends StatelessWidget {
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;
  final String? statusActionLabel;
  final bool showStatusAction;

  const InactiveListingActionBottomSheet({
    super.key,
    required this.onStatusChange,
    required this.onDelete,
    this.statusActionLabel,
    this.showStatusAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade400,
                  size: 22.sp,
                ),
              ),
            ),
            8.height,
            if (showStatusAction) ...[
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onStatusChange();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    statusActionLabel ?? context.l10n.activate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              12.height,
            ],
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: Text(
                context.l10n.delete,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            4.height,
          ],
        ),
      ),
    );
  }
}

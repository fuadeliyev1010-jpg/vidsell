import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/login/page/login_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// "Məlumatlar silinsin?" — confirms discarding entered form data
/// when the user tries to leave the registration screen.
class DiscardDataDialog extends StatelessWidget {
  const DiscardDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.bgSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.discardDataTitle,
              style: AppTextStyle.primaryText.copyWith(fontSize: 16.sp),
            ),
            17.height,
            Text(
              context.l10n.discardDataDescription,
              style: AppTextStyle.specialText.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.start,
            ),
            8.height,
            IntrinsicHeight(
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 120.w,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        context.l10n.stayOnForm,
                        style: AppTextStyle.primaryText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.goAndClear(const LoginPage()),
                    child: Text(
                      context.l10n.delete,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

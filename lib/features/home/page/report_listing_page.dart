import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ReportListingPage extends StatefulWidget {
  const ReportListingPage({
    super.key,
    required this.listingId,
    this.repository,
  });

  final String listingId;
  final EngagementRepository? repository;

  @override
  State<ReportListingPage> createState() => _ReportListingPageState();
}

class _ReportListingPageState extends State<ReportListingPage> {
  int? _selectedReasonIndex;
  bool _isSubmitting = false;
  final TextEditingController _descriptionController = TextEditingController();

  List<String> _reasons(AppLocalizations l10n) => [
    l10n.reportSpam,
    l10n.reportListingNotCurrent,
    l10n.reportProhibitedItem,
    l10n.reportDuplicate,
    l10n.reportWrongCategory,
    l10n.reportFraud,
    l10n.other,
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _reasons(context.l10n);
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: context.goBack,
                    child: Icon(Icons.close, color: Colors.white, size: 22.sp),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.l10n.reportListing,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  22.width, // Spacer for back button symmetry
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Text(
                      context.l10n.selectReason,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    12.height,

                    // Reasons Options List
                    ...List.generate(reasons.length, (index) {
                      final isSelected = _selectedReasonIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedReasonIndex = index),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF11141B),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : const Color(0xFF1E232E),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  reasons[index],
                                  style: AppTextStyle.primaryText.copyWith(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                Container(
                                  width: 18.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF00D4FF)
                                          : Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 8.w,
                                            height: 8.h,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF00D4FF),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    12.height,

                    // Description Label
                    RichText(
                      text: TextSpan(
                        text: context.l10n.describeReport,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                        ),
                        children: const [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    8.height,

                    // Description Input Box
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF11141B),
                        hintText: context.l10n.describePlaceholder,
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E232E),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF00D4FF),
                          ),
                        ),
                      ),
                    ),

                    24.height,

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed:
                            !_isSubmitting &&
                                _selectedReasonIndex != null &&
                                _descriptionController.text.trim().isNotEmpty
                            ? _submitReport
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C222E),
                          disabledBackgroundColor: const Color(0xFF1A1D24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          _isSubmitting
                              ? context.l10n.pleaseWait
                              : context.l10n.send,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    16.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final reason = _reasons(context.l10n)[_selectedReasonIndex!];
    setState(() => _isSubmitting = true);
    try {
      await (widget.repository ?? context.read<EngagementRepository>())
          .reportListing(
            listingId: widget.listingId,
            reason: reason,
            description: _descriptionController.text.trim(),
          );
      if (mounted) context.goBack();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

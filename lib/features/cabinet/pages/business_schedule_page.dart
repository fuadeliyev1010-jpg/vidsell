import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/cabinet/pages/business_contact_page.dart';
import 'package:vidsell/features/cabinet/widgets/business_schedule_widgets.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/models/store/my_store.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessSchedulePage extends StatefulWidget {
  const BusinessSchedulePage({super.key, required this.draft});

  final StoreDraft draft;

  @override
  State<BusinessSchedulePage> createState() => _BusinessSchedulePageState();
}

class _BusinessSchedulePageState extends State<BusinessSchedulePage> {
  bool _isAlwaysOpen = false;
  bool _isGeneralSchedule = true;
  final Set<String> _selectedDays = {'Bazar ertəsi'};
  TimeOfDay _openingTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72.h),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 64.h,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: context.goBack,
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColor.tertiaryTextColor,
                        size: 24.sp,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.stepTwoOfThree,
                      style: AppTextStyle.primaryText.copyWith(fontSize: 16.sp),
                    ),
                    16.width,
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColor.bgSecondary,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15.w, 18.h, 15.w, 24.h),
          child: Column(
            children: [
              BusinessScheduleEditor(
                isAlwaysOpen: _isAlwaysOpen,
                isGeneralSchedule: _isGeneralSchedule,
                selectedDays: _selectedDays,
                openingTime: _openingTime,
                closingTime: _closingTime,
                onAlwaysOpenChanged: (value) =>
                    setState(() => _isAlwaysOpen = value),
                onScheduleTypeChanged: (value) =>
                    setState(() => _isGeneralSchedule = value),
                onDayToggled: _toggleDay,
                onOpeningChanged: (time) => setState(() => _openingTime = time),
                onClosingChanged: (time) => setState(() => _closingTime = time),
                showLegacyControls: context.read<AppConfig>().useMockBackend,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 8.h, 15.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: context.l10n.clear,
                color: AppColor.bgElavated,
                height: 48.h,
                onPressed: _clearSchedule,
              ),
            ),
            8.width,
            Expanded(
              child: AppButton(
                text: context.l10n.continueAction,
                height: 48.h,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    final store = await context.goTo<MyStore>(
      BusinessContactPage(
        draft: widget.draft.copyWith(
          alwaysOpen: _isAlwaysOpen,
          openDays: List.unmodifiable(_selectedDays),
          openingTime: formatBusinessScheduleTime(_openingTime),
          closingTime: formatBusinessScheduleTime(_closingTime),
        ),
      ),
    );
    if (mounted && store != null) context.goBack(store);
  }

  void _clearSchedule() {
    setState(() {
      _isAlwaysOpen = false;
      _isGeneralSchedule = true;
      _selectedDays.clear();
      _openingTime = const TimeOfDay(hour: 0, minute: 0);
      _closingTime = const TimeOfDay(hour: 0, minute: 0);
    });
  }
}

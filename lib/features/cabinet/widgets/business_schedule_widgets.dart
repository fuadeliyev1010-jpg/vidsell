import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

const businessScheduleDays = [
  'Bazar ertəsi',
  'Çərşənbə axşamı',
  'Çərşənbə',
  'Cümə axşamı',
  'Cümə',
  'Şənbə',
  'Bazar',
];

/// The day names above are stored values (sent to / read from the backend),
/// so they stay as identifiers. This maps them to the localized label.
String localizedScheduleDay(BuildContext context, String day) {
  final l10n = context.l10n;
  return switch (day) {
    'Bazar ertəsi' => l10n.weekdayMonday,
    'Çərşənbə axşamı' => l10n.weekdayTuesday,
    'Çərşənbə' => l10n.weekdayWednesday,
    'Cümə axşamı' => l10n.weekdayThursday,
    'Cümə' => l10n.weekdayFriday,
    'Şənbə' => l10n.weekdaySaturday,
    'Bazar' => l10n.weekdaySunday,
    _ => day,
  };
}

String formatBusinessScheduleTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

class BusinessScheduleTypeSelector extends StatelessWidget {
  const BusinessScheduleTypeSelector({
    super.key,
    required this.isGeneralSchedule,
    required this.onChanged,
  });

  final bool isGeneralSchedule;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _ScheduleTypeButton(
            label: context.l10n.generalSchedule,
            selected: isGeneralSchedule,
            onTap: () => onChanged(true),
          ),
          _ScheduleTypeButton(
            label: context.l10n.individualSchedule,
            selected: !isGeneralSchedule,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTypeButton extends StatelessWidget {
  const _ScheduleTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColor.bgElavated : Colors.transparent,
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Text(
            label,
            style: AppTextStyle.primaryText.copyWith(fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}

class BusinessScheduleDayChip extends StatelessWidget {
  const BusinessScheduleDayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String day;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: (!enabled || selected)
              ? AppColor.activeColor
              : AppColor.bgElavated,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          localizedScheduleDay(context, day),
          style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
        ),
      ),
    );
  }
}

class BusinessScheduleTimeRange extends StatelessWidget {
  const BusinessScheduleTimeRange({
    super.key,
    required this.openingTime,
    required this.closingTime,
    required this.onOpeningChanged,
    required this.onClosingChanged,
    this.enabled = true,
  });

  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final ValueChanged<TimeOfDay> onOpeningChanged;
  final ValueChanged<TimeOfDay> onClosingChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BusinessScheduleTimeButton(
          time: openingTime,
          onChanged: onOpeningChanged,
          enabled: enabled,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            '-',
            style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
          ),
        ),
        BusinessScheduleTimeButton(
          time: closingTime,
          onChanged: onClosingChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}

class BusinessScheduleTimeButton extends StatefulWidget {
  const BusinessScheduleTimeButton({
    super.key,
    required this.time,
    required this.onChanged,
    this.enabled = true,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  final bool enabled;

  @override
  State<BusinessScheduleTimeButton> createState() =>
      _BusinessScheduleTimeButtonState();
}

class _BusinessScheduleTimeButtonState
    extends State<BusinessScheduleTimeButton> {
  bool _isOpen = false;

  static final List<TimeOfDay> _options = List.generate(
    48,
    (index) => TimeOfDay(hour: index ~/ 2, minute: (index % 2) * 30),
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TimeOfDay>(
      tooltip: '',
      enabled: widget.enabled,
      position: PopupMenuPosition.under,
      offset: Offset(0, 4.h),
      color: AppColor.bgElavated,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: 86.w,
        maxWidth: 86.w,
        maxHeight: 220.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      onOpened: () => setState(() => _isOpen = true),
      onCanceled: () => setState(() => _isOpen = false),
      onSelected: (value) {
        setState(() => _isOpen = false);
        widget.onChanged(value);
      },
      itemBuilder: (context) => _options.asMap().entries.map((entry) {
        final isLast = entry.key == _options.length - 1;
        return PopupMenuItem<TimeOfDay>(
          value: entry.value,
          height: 40.h,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColor.bgSecondary, width: 1),
                    ),
            ),
            child: Text(
              formatBusinessScheduleTime(entry.value),
              style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
            ),
          ),
        );
      }).toList(),
      child: Container(
        width: 86.w,
        height: 33.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColor.bgElavated,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: _isOpen ? AppColor.activeColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(
              formatBusinessScheduleTime(widget.time),
              style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
            ),
            const Spacer(),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: _isOpen
                  ? AppColor.activeColor
                  : AppColor.tertiaryTextColor,
              size: 15.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessScheduleSummary extends StatelessWidget {
  const BusinessScheduleSummary({
    super.key,
    required this.isAlwaysOpen,
    required this.selectedDays,
    required this.openingTime,
    required this.closingTime,
    this.title,
  });

  final bool isAlwaysOpen;
  final Set<String> selectedDays;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final schedule = isAlwaysOpen
        ? AppLocalizations.of(context)!.open247
        : selectedDays.isEmpty
        ? context.l10n.noWorkingDaysSelected
        : '${selectedDays.map((day) => localizedScheduleDay(context, day)).join(', ')}: '
              '${formatBusinessScheduleTime(openingTime)} - '
              '${formatBusinessScheduleTime(closingTime)}';

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? context.l10n.scheduleSummary,
            style: AppTextStyle.primaryText.copyWith(fontSize: 14.sp),
          ),
          4.height,
          Text(
            schedule,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.mutedText.copyWith(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

class BusinessScheduleEditor extends StatelessWidget {
  const BusinessScheduleEditor({
    super.key,
    required this.isAlwaysOpen,
    required this.isGeneralSchedule,
    required this.selectedDays,
    required this.openingTime,
    required this.closingTime,
    required this.onAlwaysOpenChanged,
    required this.onScheduleTypeChanged,
    required this.onDayToggled,
    required this.onOpeningChanged,
    required this.onClosingChanged,
    this.title,
    this.summaryTitle,
  });

  final bool isAlwaysOpen;
  final bool isGeneralSchedule;
  final Set<String> selectedDays;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final ValueChanged<bool> onAlwaysOpenChanged;
  final ValueChanged<bool> onScheduleTypeChanged;
  final ValueChanged<String> onDayToggled;
  final ValueChanged<TimeOfDay> onOpeningChanged;
  final ValueChanged<TimeOfDay> onClosingChanged;
  final String? title;
  final String? summaryTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScheduleCard(context),
        8.height,
        if (isGeneralSchedule)
          _buildGeneralSchedule(context)
        else
          _buildIndividualSchedule(context),
        BusinessScheduleSummary(
          isAlwaysOpen: isAlwaysOpen,
          selectedDays: selectedDays,
          openingTime: openingTime,
          closingTime: closingTime,
          title: summaryTitle,
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? context.l10n.scheduleTitle,
            style: AppTextStyle.primaryText.copyWith(fontSize: 16.sp),
          ),
          14.height,
          BusinessScheduleTypeSelector(
            isGeneralSchedule: isGeneralSchedule,
            onChanged: onScheduleTypeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSchedule(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.open247,
                  style: AppTextStyle.primaryText.copyWith(fontSize: 14.sp),
                ),
              ),
              Switch(
                value: isAlwaysOpen,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColor.activeColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColor.tertiaryTextColor,
                onChanged: onAlwaysOpenChanged,
              ),
            ],
          ),
          Text(
            context.l10n.open247Description,
            style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
          ),
          24.height,
          Text(
            context.l10n.selectWorkDays,
            style: AppTextStyle.primaryText.copyWith(fontSize: 14.sp),
          ),
          14.height,
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: businessScheduleDays
                .map((day) {
                  final selected = selectedDays.contains(day);
                  return BusinessScheduleDayChip(
                    day: day,
                    selected: selected,
                    enabled: !isAlwaysOpen,
                    onTap: () => onDayToggled(day),
                  );
                })
                .toList(growable: false),
          ),
          24.height,
          BusinessScheduleTimeRange(
            openingTime: openingTime,
            closingTime: closingTime,
            onOpeningChanged: onOpeningChanged,
            onClosingChanged: onClosingChanged,
            enabled: !isAlwaysOpen,
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.workDaysAndHours,
          style: AppTextStyle.primaryText.copyWith(fontSize: 11.sp),
        ),
        10.height,
        ...businessScheduleDays.map((day) {
          final selected = selectedDays.contains(day);
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onDayToggled(day),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: selected
                            ? AppColor.activeColor
                            : AppColor.tertiaryTextColor,
                        size: 17.sp,
                      ),
                      6.width,
                      Text(
                        day,
                        style: AppTextStyle.primaryText.copyWith(
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                8.height,
                BusinessScheduleTimeRange(
                  openingTime: openingTime,
                  closingTime: closingTime,
                  onOpeningChanged: onOpeningChanged,
                  onClosingChanged: onClosingChanged,
                  enabled: selected && !isAlwaysOpen,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

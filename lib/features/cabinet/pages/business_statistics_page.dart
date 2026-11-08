import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessStatisticsPage extends StatefulWidget {
  const BusinessStatisticsPage({super.key, required this.businessId});

  final String businessId;

  @override
  State<BusinessStatisticsPage> createState() => _BusinessStatisticsPageState();
}

class _BusinessStatisticsPageState extends State<BusinessStatisticsPage> {
  List<String> get _dayLabels => [
    context.l10n.weekdayMondayShort,
    context.l10n.weekdayTuesdayShort,
    context.l10n.weekdayWednesdayShort,
    context.l10n.weekdayThursdayShort,
    context.l10n.weekdayFridayShort,
    context.l10n.weekdaySaturdayShort,
    context.l10n.weekdaySundayShort,
  ];

  late final BusinessRepository _repository;
  late Future<BusinessAnalytics> _analyticsFuture;
  String _period = '7d';

  @override
  void initState() {
    super.initState();
    _repository = context.read<BusinessRepository>();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    _analyticsFuture = _repository.fetchAnalytics(
      widget.businessId,
      period: _period,
    );
  }

  void _selectPeriod(String period) {
    if (period == _period) return;
    setState(() {
      _period = period;
      _loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.statistics),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<BusinessAnalytics>(
                future: _analyticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error);
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.activeColor,
                      ),
                    );
                  }
                  return _buildStatistics(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildStatistics(BusinessAnalytics analytics) {
    return ListView(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 18.h),
      children: [
        Row(
          children: [
            _buildPeriodButton(context.l10n.lastSevenDays, '7d'),
            8.width,
            _buildPeriodButton(context.l10n.lastThirtyDays, '30d'),
          ],
        ),
        20.height,
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(analytics.views, context.l10n.views),
            ),
            8.width,
            Expanded(
              child: _buildSummaryCard(
                analytics.searches,
                context.l10n.searches,
              ),
            ),
            8.width,
            Expanded(
              child: _buildSummaryCard(
                analytics.messages,
                context.l10n.messageSingular,
              ),
            ),
          ],
        ),
        16.height,
        _buildChartSection(context.l10n.views, analytics.viewsByDay),
        16.height,
        _buildChartSection(context.l10n.searches, analytics.searchesByDay),
        16.height,
        _buildChartSection(
          context.l10n.messageSingular,
          analytics.messagesByDay,
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final selected = _period == period;
    return InkWell(
      onTap: () => _selectPeriod(period),
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        height: 33.h,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF10202C) : AppColor.bgSurfaceColor,
            border: Border.all(
              color: selected ? AppColor.activeColor : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            style: AppTextStyle.primaryText.copyWith(
              color: selected
                  ? AppColor.activeColor
                  : AppColor.tertiaryTextColor,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int value, String label) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatCount(value),
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
          Text(label, style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, List<int> dailyValues) {
    final values = _chartValues(dailyValues);
    final labels = _chartLabels(dailyValues.length, values.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        14.height,
        Container(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          decoration: BoxDecoration(
            color: AppColor.bgSurfaceColor,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: values.isEmpty
              ? SizedBox(
                  height: 100.h,
                  child: Center(
                    child: Text(
                      context.l10n.noDailyStats,
                      style: AppTextStyle.mutedText.copyWith(fontSize: 9.sp),
                    ),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 205.h,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _StatisticsChartPainter(
                          values: values,
                          barColor: AppColor.activeColor,
                          labelColor: AppColor.tertiaryTextColor,
                        ),
                      ),
                    ),
                    2.height,
                    Row(
                      children: List.generate(values.length, (index) {
                        return Expanded(
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            style: AppTextStyle.mutedText.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  List<int> _chartValues(List<int> values) {
    if (values.length <= 7) return values;
    final buckets = List<int>.filled(7, 0);
    for (var index = 0; index < values.length; index++) {
      final bucket = index * 7 ~/ values.length;
      buckets[bucket] += values[index];
    }
    return buckets;
  }

  List<String> _chartLabels(int originalLength, int bucketCount) {
    if (originalLength <= 7) {
      return List.generate(
        bucketCount,
        (index) => _dayLabels[index % _dayLabels.length],
      );
    }
    return List.generate(bucketCount, (index) {
      final start = (index * originalLength + bucketCount - 1) ~/ bucketCount;
      final end =
          ((index + 1) * originalLength + bucketCount - 1) ~/ bucketCount - 1;
      return '${start + 1}-${end + 1}';
    });
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.businessStatsError,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
            8.height,
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTextStyle.mutedText.copyWith(fontSize: 10.sp),
            ),
            8.height,
            TextButton(
              onPressed: () => setState(_loadAnalytics),
              child: Text(
                context.l10n.retryAgain,
                style: TextStyle(color: AppColor.activeColor, fontSize: 11.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      if (index > 0 && (text.length - index) % 3 == 0) buffer.write(',');
      buffer.write(text[index]);
    }
    return buffer.toString();
  }
}

class _StatisticsChartPainter extends CustomPainter {
  const _StatisticsChartPainter({
    required this.values,
    required this.barColor,
    required this.labelColor,
  });

  final List<int> values;
  final Color barColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftGutter = 26.0;
    const rightGutter = 2.0;
    const topGutter = 4.0;
    const bottomGutter = 4.0;
    final chartWidth = size.width - leftGutter - rightGutter;
    final chartHeight = size.height - topGutter - bottomGutter;
    final maximum = values.reduce(math.max);
    final axisMaximum = _axisMaximum(maximum);
    final gridPaint = Paint()
      ..color = const Color(0xFF3A414D)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    final barPaint = Paint()
      ..color = barColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final highlightedBarPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    final textStyle = TextStyle(
      color: labelColor.withValues(alpha: 0.75),
      fontSize: 7.sp,
    );

    for (var line = 0; line < 3; line++) {
      final fraction = line / 2;
      final y = topGutter + chartHeight * fraction;
      canvas.drawLine(
        Offset(leftGutter, y),
        Offset(size.width - rightGutter, y),
        gridPaint,
      );
      final axisValue = (axisMaximum * (1 - fraction)).round();
      final textPainter = TextPainter(
        text: TextSpan(text: _formatAxisValue(axisValue), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftGutter - 3);
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    final slotWidth = chartWidth / values.length;
    final barWidth = math.min(slotWidth * 0.72, 28.w);
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      final barHeight = chartHeight * value / axisMaximum;
      final left = leftGutter + slotWidth * index + (slotWidth - barWidth) / 2;
      final top = topGutter + chartHeight - barHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: Radius.circular(4.r),
        topRight: Radius.circular(4.r),
      );
      canvas.drawRRect(
        rect,
        index == values.length - 1 ? highlightedBarPaint : barPaint,
      );
    }
  }

  int _axisMaximum(int value) {
    if (value <= 0) return 1;
    final magnitude = math.pow(10, (math.log(value) / math.ln10).floor());
    final normalized = value / magnitude;
    final rounded = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 5
        ? 5
        : 10;
    return (rounded * magnitude).ceil();
  }

  String _formatAxisValue(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands == thousands.roundToDouble() ? thousands.toInt() : thousands}k';
    }
    return '$value';
  }

  @override
  bool shouldRepaint(covariant _StatisticsChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.barColor != barColor ||
      oldDelegate.labelColor != labelColor;
}

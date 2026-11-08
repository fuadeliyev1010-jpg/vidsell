import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/store/store_statistics.dart';

class BusinessStatisticsPage extends StatefulWidget {
  const BusinessStatisticsPage({super.key});

  @override
  State<BusinessStatisticsPage> createState() => _BusinessStatisticsPageState();
}

class _BusinessStatisticsPageState extends State<BusinessStatisticsPage> {
  late final Future<StoreStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = context
        .read<BusinessRepository>()
        .fetchMyStoreStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.statistics),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<StoreStatistics>(
          future: _statisticsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(context.l10n.genericError));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.activeColor),
              );
            }
            final statistics = snapshot.data!;
            final cards = [
              if (statistics.views != null)
                _StatisticsCard(statistics.views!, context.l10n.views),
              if (statistics.listings != null)
                _StatisticsCard(statistics.listings!, context.l10n.myListings),
              if (statistics.followers != null)
                _StatisticsCard(statistics.followers!, context.l10n.followers),
            ];
            return ListView(
              padding: EdgeInsets.all(12.w),
              children: [Wrap(spacing: 8.w, runSpacing: 8.h, children: cards)],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minWidth: 100.w),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: AppColor.bgSecondary,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        4.height,
        Text(label, style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp)),
      ],
    ),
  );
}

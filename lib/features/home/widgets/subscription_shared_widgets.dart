import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class SubscriptionBonusBox extends StatelessWidget {
  final Widget previousContent;
  final Widget currentContent;

  const SubscriptionBonusBox({
    super.key,
    required this.previousContent,
    required this.currentContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151921),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                context.l10n.bonus,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.black,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 44.w,
                      child: Text(
                        context.l10n.subscriptionBefore,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    previousContent,
                  ],
                ),
                12.height,
                Row(
                  children: [
                    SizedBox(
                      width: 44.w,
                      child: Text(
                        context.l10n.subscriptionNow,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    currentContent,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlansList extends StatelessWidget {
  final List<Map<String, String>> plans;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? freePlanLabel;

  const SubscriptionPlansList({
    super.key,
    required this.plans,
    required this.selectedIndex,
    required this.onSelect,
    this.freePlanLabel,
    this.currency = fallbackCurrencyCode,
  });

  final String currency;

  @override
  Widget build(BuildContext context) {
    final hasFreePlan = freePlanLabel != null;
    final rowCount = plans.length + (hasFreePlan ? 1 : 0);

    return Column(
      children: List.generate(rowCount, (index) {
        final isFreePlan = hasFreePlan && index == 0;
        final planIndex = index - (hasFreePlan ? 1 : 0);
        final plan = isFreePlan ? null : plans[planIndex];
        final isSelected = selectedIndex == index;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              height: 73.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF12222E)
                    : const Color(0xFF11141B),
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
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            isFreePlan
                                ? freePlanLabel!
                                : '${plan!['duration']} / '
                                      '${CurrencyFormatter.formatPriceText(plan['price']!, plan['currency'] ?? currency)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.primaryText.copyWith(
                              color: isSelected
                                  ? const Color(0xFF00D4FF)
                                  : Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isFreePlan) ...[
                          8.width,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E3028),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              context.l10n.free,
                              style: AppTextStyle.primaryText.copyWith(
                                color: AppColor.successLight,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
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
    );
  }
}

class SubscriptionPaymentMethods extends StatelessWidget {
  final List<String> methods;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const SubscriptionPaymentMethods({
    super.key,
    required this.methods,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            context.l10n.subscriptionMethod,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        16.height,
        ...List.generate(methods.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                height: 73.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF12222E)
                      : const Color(0xFF11141B),
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
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              methods[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.primaryText.copyWith(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (index == 0) ...[
                            8.width,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  2.width,
                                  Text(
                                    context.l10n.pay,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
      ],
    );
  }
}

class SubscriptionPayButton extends StatelessWidget {
  final VoidCallback onTap;

  const SubscriptionPayButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          color: const Color(0xFF38B6FF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            context.l10n.pay,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionDisclaimer extends StatelessWidget {
  const SubscriptionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        AppLocalizations.of(context)!.subscriptionAccepted,
        textAlign: TextAlign.center,
        style: AppTextStyle.primaryText.copyWith(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10.sp,
          height: 1.5,
        ),
      ),
    );
  }
}

class SubscriptionHeader extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String title;
  final VoidCallback onBackTap;

  const SubscriptionHeader({
    super.key,
    this.icon,
    this.iconColor = Colors.white,
    required this.title,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            child: GestureDetector(
              onTap: onBackTap,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 20.sp),
                  8.width,
                ],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }
}

class SubscriptionDateBanner extends StatelessWidget {
  final String dateText;
  final double? opacity;

  const SubscriptionDateBanner({
    super.key,
    required this.dateText,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      color: const Color(0xFF151921),
      child: Center(
        child: Text(
          dateText,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white.withValues(alpha: opacity ?? 0.7),
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}

class SubscriptionBenefitChip extends StatelessWidget {
  const SubscriptionBenefitChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          4.width,
          Text(
            label,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionMonthlyLimit extends StatelessWidget {
  const SubscriptionMonthlyLimit({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final nextRenewalDate = Localizations.localeOf(context).languageCode == 'tr'
        ? '1 Kasım 2026'
        : 'November 1, 2026';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF191D24),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.subscriptionRemaining('1'),
                style: AppTextStyle.primaryText.copyWith(
                  color: AppColor.success,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          10.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 6.h,
              backgroundColor: const Color(0xFF2A303B),
              valueColor: const AlwaysStoppedAnimation(AppColor.activeColor),
            ),
          ),
          10.height,
          Text(
            AppLocalizations.of(context)!.subscriptionRenewal(nextRenewalDate),
            style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPurchasePage extends StatefulWidget {
  const SubscriptionPurchasePage({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.limitTitle,
    required this.plans,
    required this.onBackTap,
    required this.onFreeActivate,
    required this.onPaidActivate,
    this.benefits,
    this.freePlanLabel,
    this.currency = fallbackCurrencyCode,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String description;
  final String limitTitle;
  final List<Map<String, String>> plans;
  final Widget? benefits;
  final VoidCallback onBackTap;
  final VoidCallback onFreeActivate;
  final VoidCallback onPaidActivate;
  final String? freePlanLabel;
  final String currency;

  @override
  State<SubscriptionPurchasePage> createState() =>
      _SubscriptionPurchasePageState();
}

class _SubscriptionPurchasePageState extends State<SubscriptionPurchasePage> {
  List<String> _paymentMethods(BuildContext context) => [
    context.l10n.bankCard,
    context.l10n.terminalPayment,
    context.l10n.personalAccountPayment(
      CurrencyFormatter.formatPrice(0, widget.currency, decimalDigits: 2),
    ),
  ];

  int _selectedPlanIndex = 0;
  int _selectedPaymentIndex = 0;

  bool get _isFreePlan => _selectedPlanIndex == 0;

  String get _selectedPlanPrice =>
      _isFreePlan ? '0,00' : widget.plans[_selectedPlanIndex - 1]['price']!;
  String get _selectedPlanCurrency => _isFreePlan
      ? widget.currency
      : widget.plans[_selectedPlanIndex - 1]['currency'] ?? widget.currency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: Column(
          children: [
            SubscriptionHeader(
              icon: widget.icon,
              iconColor: widget.iconColor,
              title: widget.title,
              onBackTap: widget.onBackTap,
            ),
            10.height,
            Divider(height: 1.h, color: AppColor.bgSecondary),
            14.height,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.description,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                    if (widget.benefits != null) ...[
                      12.height,
                      widget.benefits!,
                    ],
                    16.height,
                    SubscriptionMonthlyLimit(title: widget.limitTitle),
                    16.height,
                    Center(
                      child: Text(
                        context.l10n.serviceDuration,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    10.height,
                    SubscriptionPlansList(
                      plans: widget.plans,
                      selectedIndex: _selectedPlanIndex,
                      freePlanLabel:
                          widget.freePlanLabel ?? context.l10n.threeDays,
                      currency: widget.currency,
                      onSelect: (index) =>
                          setState(() => _selectedPlanIndex = index),
                    ),
                    if (!_isFreePlan) ...[
                      4.height,
                      SubscriptionPaymentMethods(
                        methods: _paymentMethods(context),
                        selectedIndex: _selectedPaymentIndex,
                        onSelect: (index) =>
                            setState(() => _selectedPaymentIndex = index),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          color: const Color(0xFF191D24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.amountDue,
                      style: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPriceText(
                      _selectedPlanPrice,
                      _selectedPlanCurrency,
                    ),
                    style: AppTextStyle.primaryText.copyWith(
                      color: AppColor.success,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              8.height,
              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  onPressed: _isFreePlan
                      ? widget.onFreeActivate
                      : widget.onPaidActivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.activeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    _isFreePlan
                        ? context.l10n.activateFree
                        : context.l10n.activateNow,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriptionDescriptionSection extends StatelessWidget {
  final String description;
  final Widget bonusBoxContent;
  final Widget bonusBoxPreviousContent;

  const SubscriptionDescriptionSection({
    super.key,
    required this.description,
    required this.bonusBoxContent,
    required this.bonusBoxPreviousContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          12.height,
          Text(
            description,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          16.height,
          SubscriptionBonusBox(
            previousContent: bonusBoxPreviousContent,
            currentContent: bonusBoxContent,
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlanSection extends StatelessWidget {
  final List<Map<String, String>> plans;
  final int selectedPlanIndex;
  final ValueChanged<int> onPlanSelect;
  final List<String> paymentMethods;
  final int selectedPaymentIndex;
  final ValueChanged<int> onPaymentSelect;
  final VoidCallback onPayTap;
  final String currency;

  const SubscriptionPlanSection({
    super.key,
    required this.plans,
    required this.selectedPlanIndex,
    required this.onPlanSelect,
    required this.paymentMethods,
    required this.selectedPaymentIndex,
    required this.onPaymentSelect,
    required this.onPayTap,
    this.currency = fallbackCurrencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Text(
            context.l10n.serviceDuration,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          16.height,
          SubscriptionPlansList(
            plans: plans,
            selectedIndex: selectedPlanIndex,
            currency: currency,
            onSelect: onPlanSelect,
          ),
          24.height,
          SubscriptionPaymentMethods(
            methods: paymentMethods,
            selectedIndex: selectedPaymentIndex,
            onSelect: onPaymentSelect,
          ),
          24.height,
          SubscriptionPayButton(onTap: onPayTap),
          16.height,
          const SubscriptionDisclaimer(),
          32.height,
        ],
      ),
    );
  }
}

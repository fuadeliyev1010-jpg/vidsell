import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/top_up_payment_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// Screen 1: Wallet Page (Pul kisəsi)
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [10, 20, 50, 100];
  int? _selectedQuickAmount;
  late Future<WalletBalance> _walletFuture;

  @override
  void initState() {
    super.initState();
    _walletFuture = context.read<WalletRepository>().fetchWallet();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18.sp,
          ),
          onPressed: context.goBack,
        ),
        title: Text(
          context.l10n.wallet,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              FutureBuilder<WalletBalance>(
                future: _walletFuture,
                builder: (context, snapshot) => _buildBalanceCard(
                  snapshot.data,
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                ),
              ),
              16.height,
              _buildTopUpCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletBalance? wallet, {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFF232D3B),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(8.r),
            child: Center(
              child: SvgPicture.asset('assets/icons/Group_wallet.svg'),
            ),
          ),
          14.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.walletBalance,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
              ),
              4.height,
              Text(
                isLoading
                    ? '...'
                    : CurrencyFormatter.formatPrice(
                        wallet?.balance ?? 0,
                        wallet?.currency ?? fallbackCurrencyCode,
                        decimalDigits: 2,
                      ),
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.topUpBalance,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          16.height,
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            onChanged: (val) {
              if (_selectedQuickAmount != null &&
                  val != _selectedQuickAmount.toString()) {
                setState(() {
                  _selectedQuickAmount = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: context.l10n.amountAzn,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF222B38),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColor.activeColor, width: 1.w),
              ),
            ),
          ),
          14.height,
          Row(
            children: _quickAmounts.map((amount) {
              final isSelected = _selectedQuickAmount == amount;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkWell(
                    onTap: () => _selectQuickAmount(amount),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.activeColor
                            : const Color(0xFF222B38),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$amount',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade300,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          20.height,
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () async {
                final l10n = context.l10n;
                final messenger = ScaffoldMessenger.of(context);
                final walletRepository = context.read<WalletRepository>();
                final amount = double.tryParse(
                  _amountController.text.replaceAll(',', '.'),
                );
                final wallet = await _walletFuture;
                if (!context.mounted) return;
                if (amount == null || amount < 1 || amount > 5000) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.amountRangeError(
                          CurrencyFormatter.formatCurrency(wallet.currency),
                        ),
                      ),
                    ),
                  );
                  return;
                }
                await context.goTo(
                  TopUpPaymentPage(amount: amount, currency: wallet.currency),
                );
                if (!mounted) return;
                setState(() => _walletFuture = walletRepository.fetchWallet());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                context.l10n.topUpBalance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

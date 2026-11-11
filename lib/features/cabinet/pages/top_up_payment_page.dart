import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/cabinet/repositories/payment_provider.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/enums/top_up_status.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';
import 'package:vidsell/models/wallet/top_up_request.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class TopUpPaymentPage extends StatefulWidget {
  final double amount;
  final String currency;

  const TopUpPaymentPage({
    super.key,
    required this.amount,
    this.currency = fallbackCurrencyCode,
  });

  @override
  State<TopUpPaymentPage> createState() => _TopUpPaymentPageState();
}

class _TopUpPaymentPageState extends State<TopUpPaymentPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isSubmitting = false;
  late final bool _isMockBackend;
  String? _selectedPaymentMethod;
  TopUpIntent? _topUpIntent;

  @override
  void dispose() {
    _fullNameController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isMockBackend = context.read<AppConfig>().useMockBackend;
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
          context.l10n.topUpBalance,
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
              _buildPaymentSummaryCard(),
              16.height,
              _buildCardFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context.l10n.amountToPay,
            CurrencyFormatter.formatPrice(
              widget.amount,
              widget.currency,
              decimalDigits: 2,
            ),
          ),
          if (_isMockBackend) ...[
            10.height,
            _buildSummaryRow(
              context.l10n.sellerLabel,
              'Vidsell.az',
              isHighlighted: true,
            ),
            10.height,
            _buildSummaryRow(context.l10n.taxId, '930726'),
            10.height,
            _buildSummaryRow(context.l10n.phone, '+994 12 345 67 89'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? AppColor.activeColor : Colors.white,
            fontSize: 13.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFormCard() {
    if (!_isMockBackend) return _buildApiTopUpCard();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildDarkTextField(
            controller: _fullNameController,
            hintText: context.l10n.nameAndSurname,
          ),
          12.height,
          _buildDarkTextField(
            controller: _cardNumberController,
            hintText: context.l10n.cardNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: _buildDarkTextField(
                  controller: _expiryMonthController,
                  hintText: context.l10n.month,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
              12.width,
              Expanded(
                child: _buildDarkTextField(
                  controller: _expiryYearController,
                  hintText: context.l10n.year,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
            ],
          ),
          12.height,
          _buildDarkTextField(
            controller: _cvvController,
            hintText: context.l10n.cvv,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),
          20.height,
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
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

  Widget _buildApiTopUpCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Builder(
        builder: (context) {
          const methods = PaymentMethod.values;
          final currentMethod =
              methods
                  .where((method) => method.code == _selectedPaymentMethod)
                  .firstOrNull ??
              methods.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: currentMethod.code,
                dropdownColor: AppColor.bgSurfaceColor,
                decoration: InputDecoration(
                  labelText: context.l10n.paymentMethod,
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                ),
                items: [
                  for (final method in methods)
                    DropdownMenuItem(
                      value: method.code,
                      child: Text(_paymentMethodLabel(method)),
                    ),
                ],
                onChanged: _topUpIntent == null
                    ? (code) => setState(() => _selectedPaymentMethod = code)
                    : null,
              ),
              if (_topUpIntent case final intent?) ...[
                14.height,
                Text(
                  context.l10n.topUpInvoiceNumber(intent.invoiceNumber),
                  style: AppTextStyle.mutedText.copyWith(fontSize: 13.sp),
                ),
                12.height,
                SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _checkTopUpStatus,
                    child: Text(context.l10n.checkPaymentStatus),
                  ),
                ),
                if (context.read<AppConfig>().environment ==
                    AppEnvironment.development) ...[
                  8.height,
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _confirmMockTopUp,
                      child: Text(context.l10n.confirm),
                    ),
                  ),
                ],
              ] else ...[
                20.height,
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _createTopUpIntent(currentMethod),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.activeColor,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(context.l10n.topUpBalance),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _paymentMethodLabel(PaymentMethod method) => switch (method.code) {
    'CARD' => context.l10n.paymentMethodCard,
    'BANK_TRANSFER' => context.l10n.paymentMethodBankTransfer,
    _ => method.code,
  };

  Future<void> _createTopUpIntent(PaymentMethod method) async {
    if (!TopUpRequest.isValidAmount(widget.amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.amountRangeError(
              CurrencyFormatter.formatCurrency(widget.currency),
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final intent = await context.read<WalletRepository>().createTopUpIntent(
        request: TopUpRequest(amount: widget.amount, paymentMethod: method),
      );
      if (mounted) setState(() => _topUpIntent = intent);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TopUp] Create intent failed: $error\n$stackTrace');
      }
      _showRequestError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showRequestError(Object error) {
    if (!mounted) return;
    final message = error is ApiException && error.code != null
        ? '${error.code}: ${error.message}'
        : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkTopUpStatus() async {
    final intent = _topUpIntent;
    if (intent == null) return;
    setState(() => _isSubmitting = true);
    try {
      final updated = await context.read<WalletRepository>().fetchTopUpIntent(
        intent.id,
      );
      if (!mounted) return;
      setState(() => _topUpIntent = updated);
      if (TopUpStatus.fromCode(updated.status) == TopUpStatus.completed) {
        context.goBack(true);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TopUp] Status check failed: $error\n$stackTrace');
      }
      _showRequestError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmMockTopUp() async {
    final intent = _topUpIntent;
    if (intent == null) return;
    setState(() => _isSubmitting = true);
    try {
      final updated = await context.read<WalletRepository>().confirmTopUp(
        intent.id,
      );
      if (!mounted) return;
      setState(() => _topUpIntent = updated);
      if (TopUpStatus.fromCode(updated.status) == TopUpStatus.completed) {
        context.goBack(true);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TopUp] Confirmation failed: $error\n$stackTrace');
      }
      _showRequestError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitPayment() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final paymentProvider = context.read<PaymentProvider>();
      final walletRepository = context.read<WalletRepository>();
      final paymentToken = await paymentProvider.tokenizeCard(
        cardholderName: _fullNameController.text,
        cardNumber: _cardNumberController.text,
        expiryMonth: int.tryParse(_expiryMonthController.text) ?? 0,
        expiryYear: int.tryParse(_expiryYearController.text) ?? -1,
        cvv: _cvvController.text,
      );
      await walletRepository.topUpWithPaymentToken(
        amount: widget.amount,
        paymentToken: paymentToken,
      );
      if (!mounted) return;
      context.goBack(true);
    } on ArgumentError {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.paymentError)));
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFF222B38),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.activeColor, width: 1.w),
        ),
      ),
    );
  }
}

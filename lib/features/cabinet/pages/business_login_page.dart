import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/cabinet/pages/business_create_page.dart';
import 'package:vidsell/models/store/my_store.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessLoginPage extends StatefulWidget {
  const BusinessLoginPage({super.key});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final TextEditingController _phoneController = TextEditingController(
    text: '+994',
  );
  final FocusNode _phoneFocusNode = FocusNode();

  static final RegExp _phoneRegex = RegExp(
    r'^(?:\+994|994|0)?(10|50|51|55|60|70|77|99)\d{7}$',
  );

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _phoneController.selection = TextSelection.collapsed(
      offset: _phoneController.text.length,
    );
    _phoneController.addListener(_clearError);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_clearError);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  String _cleanPhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-\(\)\u00A0\u200B]'), '');
  }

  bool _isValidPhone(String value) {
    return _phoneRegex.hasMatch(_cleanPhone(value.trim()));
  }

  String _normalizePhoneNumber(String value) {
    final phone = _cleanPhone(value.trim());
    if (phone.startsWith('+994')) return phone;
    if (phone.startsWith('994')) return '+$phone';
    if (phone.startsWith('0')) return '+994${phone.substring(1)}';
    return '+994$phone';
  }

  Future<void> _sendSmsCode() async {
    final phoneNumber = _phoneController.text;
    if (!_isValidPhone(phoneNumber)) {
      setState(
        () => _errorText = phoneNumber.trim().isEmpty || phoneNumber == '(0'
            ? context.l10n.loginIdentifierRequired
            : context.l10n.loginIdentifierInvalid,
      );
      return;
    }

    final store = await context.goTo<MyStore>(
      BusinessCreatePage(phoneNumber: _normalizePhoneNumber(phoneNumber)),
    );
    if (mounted && store != null) context.goBack(store);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72.h),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 64.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: context.goBack,
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColor.tertiaryTextColor,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.businessLoginTitle,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
          padding: EdgeInsets.fromLTRB(20.w, 54.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhoneField(),
              26.height,
              AppButton(
                height: 48.h,
                text: context.l10n.smsCodeSend,
                onPressed: _sendSmsCode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.phone,
          style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
        ),
        SizedBox(
          height: 38.h,
          child: TextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
            cursorColor: AppColor.activeColor,
            decoration: const InputDecoration(
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.only(bottom: 6),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.activeColor),
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          4.height,
          Text(
            _errorText!,
            style: AppTextStyle.mutedText.copyWith(
              color: Colors.red,
              fontSize: 11.sp,
            ),
          ),
        ],
      ],
    );
  }
}

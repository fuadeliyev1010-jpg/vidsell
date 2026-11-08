import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/utils/phone_validator.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class _PhoneEntry {
  _PhoneEntry({this.country = PhoneCountry.azerbaijan, String text = ''})
    : controller = TextEditingController(text: text);

  PhoneCountry country;
  final TextEditingController controller;
}

class BusinessContactPage extends StatefulWidget {
  const BusinessContactPage({super.key, required this.draft});

  final StoreDraft draft;

  @override
  State<BusinessContactPage> createState() => _BusinessContactPageState();
}

class _BusinessContactPageState extends State<BusinessContactPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shortNumberController = TextEditingController();
  late final _PhoneEntry _mainPhone;
  final List<_PhoneEntry> _additionalPhones = [];

  final List<TextInputFormatter> _phoneFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(12),
  ];

  @override
  void initState() {
    super.initState();
    _mainPhone = _entryFromNumber(widget.draft.phoneNumber);
  }

  /// Splits "+994501234567" into country + national number.
  _PhoneEntry _entryFromNumber(String number) {
    for (final country in PhoneCountry.values) {
      final national = PhoneValidator.national(country, number);
      if (national != null) {
        return _PhoneEntry(country: country, text: national);
      }
    }
    return _PhoneEntry();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _shortNumberController.dispose();
    _mainPhone.controller.dispose();
    for (final entry in _additionalPhones) {
      entry.controller.dispose();
    }
    super.dispose();
  }

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
                      context.l10n.stepOfThree('3'),
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
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          child: _buildContactCard(),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildContactCard() {
    final isMock = context.read<AppConfig>().useMockBackend;
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
            isMock ? context.l10n.businessContact : context.l10n.generalInfo,
            style: AppTextStyle.primaryText.copyWith(fontSize: 16.sp),
          ),
          14.height,
          if (!isMock) ...[
            Text(context.l10n.storeNameLabel),
            4.height,
            Text(widget.draft.storeName.trim()),
            14.height,
            Text(context.l10n.categories),
            4.height,
            Text(widget.draft.categoryNames.join(', ')),
          ],
          if (isMock) ...[
            _FloatingField(
              controller: _emailController,
              label: context.l10n.email,
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
            ),
            14.height,
          ],
          if (isMock) ...[
            Row(
              children: [
                Expanded(child: _buildPhoneField(_mainPhone)),
                8.width,
                SizedBox(
                  width: 106.w,
                  height: 45.h,
                  child: AppButton(
                    text: context.l10n.addContact,
                    height: 45.h,
                    color: AppColor.bgElavated,
                    textColor: Colors.white,
                    onPressed: _addPhone,
                  ),
                ),
              ],
            ),
            14.height,
          ],
          if (isMock)
            for (final entry in _additionalPhones)
              Padding(
                key: ObjectKey(entry),
                padding: EdgeInsets.only(bottom: 14.h),
                child: Row(
                  children: [
                    Expanded(child: _buildPhoneField(entry)),
                    8.width,
                    SizedBox(
                      width: 106.w,
                      height: 45.h,
                      child: AppButton(
                        text: context.l10n.delete,
                        height: 45.h,
                        color: const Color(0xff32161B),
                        textColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        onPressed: () => _removePhone(entry),
                      ),
                    ),
                  ],
                ),
              ),
          if (isMock)
            _FloatingField(
              controller: _shortNumberController,
              label: context.l10n.shortNumber,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(_PhoneEntry entry) {
    return _FloatingField(
      controller: entry.controller,
      label: context.l10n.phone,
      isRequired: true,
      keyboardType: TextInputType.phone,
      inputFormatters: _phoneFormatters,
      country: entry.country,
      onCountryChanged: (country) => setState(() => entry.country = country),
    );
  }

  Widget _buildBottomActions() {
    final isMock = context.read<AppConfig>().useMockBackend;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 8.h),
        child: Row(
          children: [
            if (isMock) ...[
              Expanded(
                child: AppButton(
                  text: context.l10n.clear,
                  color: AppColor.bgElavated,
                  height: 48.h,
                  onPressed: _clearForm,
                ),
              ),
              8.width,
            ],
            Expanded(
              child: AppButton(
                text: context.l10n.send,
                height: 48.h,
                onPressed: _submitApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPhone() {
    setState(() => _additionalPhones.add(_PhoneEntry()));
  }

  void _removePhone(_PhoneEntry entry) {
    setState(() => _additionalPhones.remove(entry));
    // Dispose after the field has left the tree.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => entry.controller.dispose(),
    );
  }

  void _clearForm() {
    final removed = List<_PhoneEntry>.of(_additionalPhones);
    setState(() {
      _emailController.clear();
      _shortNumberController.clear();
      _mainPhone.controller.clear();
      _mainPhone.country = PhoneCountry.azerbaijan;
      _additionalPhones.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final entry in removed) {
        entry.controller.dispose();
      }
    });
  }

  String? _normalized(_PhoneEntry entry) =>
      PhoneValidator.normalize(entry.country, entry.controller.text);

  Future<void> _submitApplication() async {
    void showMessage(String text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    final isMock = context.read<AppConfig>().useMockBackend;
    if (isMock &&
        (_emailController.text.trim().isEmpty ||
            _mainPhone.controller.text.trim().isEmpty)) {
      showMessage(context.l10n.contactEmailAndPhoneRequired);
      return;
    }

    // Empty extra numbers are ignored, filled ones must be valid.
    final entries = [_mainPhone, ..._additionalPhones];
    final hasInvalid =
        isMock &&
        entries.any(
          (entry) =>
              entry.controller.text.trim().isNotEmpty &&
              _normalized(entry) == null,
        );
    if (hasInvalid) {
      showMessage(context.l10n.invalidContactPhone);
      return;
    }

    try {
      final requestDraft = isMock
          ? widget.draft.copyWith(
              email: _emailController.text,
              mainPhone: _normalized(_mainPhone),
              additionalPhones: entries
                  .skip(1)
                  .map(_normalized)
                  .whereType<String>()
                  .toList(growable: false),
              shortNumber: _shortNumberController.text,
            )
          : widget.draft;
      final store = await context
          .read<BusinessRepository>()
          .createStoreApplication(requestDraft);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (context) => _ApplicationAcceptedSheet(store: store),
      );
      if (mounted) context.goBack(store);
    } on ArgumentError {
      if (mounted) showMessage(context.l10n.fillRequiredFields);
    } on Exception {
      if (mounted) showMessage(context.l10n.genericError);
    }
  }
}

/// Same behaviour as the first page: 45 high when empty and unfocused,
/// a bit higher (small label on top, input below) when focused or filled.
/// If [country] is set, a flag dropdown + dial code appear while active.
class _FloatingField extends StatefulWidget {
  const _FloatingField({
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.keyboardType,
    this.inputFormatters,
    this.country,
    this.onCountryChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final PhoneCountry? country;
  final ValueChanged<PhoneCountry>? onCountryChanged;

  static double get normalHeight => 45.h;
  static double get activeHeight => 63.h;

  @override
  State<_FloatingField> createState() => _FloatingFieldState();
}

class _FloatingFieldState extends State<_FloatingField> {
  final FocusNode _focusNode = FocusNode();
  bool _menuOpen = false;

  // _menuOpen keeps the field expanded while the country menu steals focus.
  bool get _isActive =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty || _menuOpen;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_refresh);
    widget.controller.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Widget _buildCountrySelector(PhoneCountry country) {
    return PopupMenuButton<PhoneCountry>(
      tooltip: '',
      padding: EdgeInsets.zero,
      color: AppColor.bgSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onOpened: () => setState(() => _menuOpen = true),
      onCanceled: () {
        setState(() => _menuOpen = false);
        _focusNode.requestFocus();
      },
      onSelected: (value) {
        setState(() => _menuOpen = false);
        widget.onCountryChanged?.call(value);
        _focusNode.requestFocus();
      },
      itemBuilder: (context) => PhoneCountry.values
          .map(
            (c) => PopupMenuItem<PhoneCountry>(
              value: c,
              child: Row(
                children: [
                  Text(c.flag, style: TextStyle(fontSize: 18.sp)),
                  8.width,
                  Text(
                    c == PhoneCountry.azerbaijan
                        ? context.l10n.regionAzerbaijan
                        : context.l10n.regionTurkey,
                    style: AppTextStyle.primaryText.copyWith(fontSize: 12.sp),
                  ),
                  8.width,
                  Text(
                    c.dialCode,
                    style: AppTextStyle.mutedText.copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flag, style: TextStyle(fontSize: 18.sp)),
          2.width,
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColor.tertiaryTextColor,
            size: 18.sp,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _isActive;
    final country = widget.country;
    final isPhone = country != null;
    const star = TextSpan(
      text: ' *',
      style: TextStyle(color: Colors.red),
    );

    final input = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: 1,
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        prefixText: isPhone && active ? '${country.dialCode} ' : null,
        prefixStyle: AppTextStyle.primaryText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        hint: isPhone && active
            ? Text(
                country.hint,
                style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
              )
            : active
            ? null
            : Text.rich(
                TextSpan(
                  text: widget.label,
                  style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                  children: [if (widget.isRequired) star],
                ),
              ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: active
            ? _FloatingField.activeHeight
            : _FloatingField.normalHeight,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.bgElavated,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (active) ...[
              Text.rich(
                TextSpan(
                  text: widget.label,
                  style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
                  children: [if (widget.isRequired) star],
                ),
              ),
              2.height,
            ],
            if (isPhone && active)
              Row(
                children: [
                  _buildCountrySelector(country),
                  8.width,
                  Expanded(child: input),
                ],
              )
            else
              input,
          ],
        ),
      ),
    );
  }
}

class _ApplicationAcceptedSheet extends StatelessWidget {
  const _ApplicationAcceptedSheet({required this.store});

  final MyStore store;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
        decoration: BoxDecoration(
          color: AppColor.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColor.success,
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: Icon(
                Icons.check,
                color: AppColor.primaryColor,
                size: 14.sp,
              ),
            ),
            18.height,
            Text(
              context.l10n.applicationAccepted,
              textAlign: TextAlign.center,
              style: AppTextStyle.primaryText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            16.height,
            Text(
              AppLocalizations.of(context)!.applicationReviewMessage,
              textAlign: TextAlign.center,
              style: AppTextStyle.mutedText.copyWith(
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            8.height,
            Text(
              AppLocalizations.of(context)!.applicationIdLabel(store.id),
              style: AppTextStyle.mutedText.copyWith(fontSize: 11.sp),
            ),
            18.height,
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Aydındır',
                height: 48.h,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

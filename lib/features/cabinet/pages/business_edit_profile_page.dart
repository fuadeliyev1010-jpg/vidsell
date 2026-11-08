import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/pages/media_picker_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/features/cabinet/widgets/business_schedule_widgets.dart';
import 'package:vidsell/features/cabinet/widgets/circle_crop_overlay_painter.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/pages/city_picker_page.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/models/store/my_store.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BusinessEditProfilePage extends StatefulWidget {
  const BusinessEditProfilePage({super.key, required this.store, this.draft});

  final MyStore store;
  final StoreDraft? draft;

  @override
  State<BusinessEditProfilePage> createState() =>
      _BusinessEditProfilePageState();
}

class _BusinessEditProfilePageState extends State<BusinessEditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _sloganController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late final TextEditingController _shortNumberController;
  late String _city;
  late List<String> _categories;
  late Set<String> _selectedDays;
  late bool _alwaysOpen;
  late bool _isGeneralSchedule;
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;
  String? _logoPath;
  String? _bannerPath;
  File? _newLogo;
  File? _newBanner;
  bool _isSaving = false;
  bool _obscurePassword = true;
  late StoreDraft _draft;

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    _draft =
        widget.draft ??
        StoreDraft(
          phoneNumber: store.phone,
          storeName: store.name,
          description: store.description,
          categoryNames: [store.category],
          mainPhone: store.phone,
          openingTime: store.workingHours.split('-').firstOrNull ?? '00:00',
          closingTime: store.workingHours.split('-').lastOrNull ?? '00:00',
          logoPath: store.logoUrl,
        );
    _nameController = TextEditingController(text: _draft.storeName);
    _sloganController = TextEditingController(text: _draft.slogan);
    _descriptionController = TextEditingController(text: _draft.description);
    _addressController = TextEditingController(text: _draft.address);
    _phoneController = TextEditingController(
      text: _draft.mainPhone.isEmpty ? _draft.phoneNumber : _draft.mainPhone,
    );
    _emailController = TextEditingController(text: _draft.email);
    _shortNumberController = TextEditingController(text: _draft.shortNumber);
    _city = _draft.city;
    _categories = List.of(_draft.categoryNames);
    _selectedDays = Set.of(_draft.openDays);
    if (_selectedDays.isEmpty) {
      _selectedDays.add(businessScheduleDays.first);
    }
    _alwaysOpen = _draft.alwaysOpen;
    _openingTime = _parseTime(_draft.openingTime);
    _closingTime = _parseTime(_draft.closingTime);
    _logoPath = _draft.logoPath;
    _bannerPath = _draft.bannerPath;
    _isGeneralSchedule = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shortNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.profileEdit),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (context.read<AppConfig>().useMockBackend) ...[
                      _buildMediaSection(),
                      12.height,
                    ],
                    _buildStoreDetails(),
                    14.height,
                    _buildScheduleSection(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context.l10n.storeLogoTitle),
          14.height,
          _buildImagePicker(
            width: 109.w,
            height: 109.w,
            path: _logoPath,
            file: _newLogo,
            onTap: () => _pickImage(isLogo: true),
          ),
          24.height,
          _hint(context.l10n.storeLogoHint),
          14.height,
          _sectionLabel(context.l10n.storeBannerTitle),
          14.height,
          _buildImagePicker(
            width: double.infinity,
            height: 85.h,
            path: _bannerPath,
            file: _newBanner,
            onTap: () => _pickImage(isLogo: false),
          ),
          14.height,
          _hint(context.l10n.storeBannerHint),
        ],
      ),
    );
  }

  Widget _buildImagePicker({
    required double width,
    required double height,
    required String? path,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: const _DashedBorderPainter(
          color: AppColor.activeColor,
          radius: 0,
        ),
        child: ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : _buildImage(path) ??
                      Icon(
                        Icons.camera_alt_rounded,
                        color: AppColor.tertiaryTextColor,
                        size: 19.sp,
                      ),
          ),
        ),
      ),
    );
  }

  Widget? _buildImage(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.camera_alt_rounded,
          color: AppColor.tertiaryTextColor,
          size: 19.sp,
        ),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.camera_alt_rounded,
        color: AppColor.tertiaryTextColor,
        size: 19.sp,
      ),
    );
  }

  Widget _buildStoreDetails() {
    final isMock = context.read<AppConfig>().useMockBackend;
    return Column(
      children: [
        _buildField(context.l10n.storeNameLabel, _nameController),
        if (isMock) ...[
          8.height,
          _buildField(context.l10n.slogan, _sloganController),
        ],
        8.height,
        _buildCategoryField(),
        8.height,
        _buildDescriptionField(),
        if (isMock) ...[
          8.height,
          _buildSelectionField(
            label: context.l10n.searchCity,
            value: _city,
            onTap: _selectCity,
          ),
          8.height,
          _buildField(context.l10n.businessEditAddress, _addressController),
        ],
        8.height,
        _buildField(
          context.l10n.businessContactNumber,
          _phoneController,
          keyboardType: TextInputType.phone,
        ),
        if (isMock) ...[
          8.height,
          _buildField(
            context.l10n.email,
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          8.height,
          _buildField(
            context.l10n.password,
            _passwordController,
            hint: context.l10n.passwordUnchangedHint,
            obscureText: _obscurePassword,
            trailing: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColor.tertiaryTextColor,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? trailing,
  }) {
    return Container(
      height: 63.h,
      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 5.h),
      decoration: BoxDecoration(
        color: AppColor.bgElevated,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                labelText: label,
                hintText: hint,
                labelStyle: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                hintStyle: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 7.h),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return _buildSelectionField(
      label: context.l10n.categories,
      value: _categories.isEmpty ? '' : _categories.join(', '),
      onTap: _selectCategories,
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 63.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColor.bgElevated,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.tertiaryTextColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 63.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 9.h, 8.w, 0),
        decoration: BoxDecoration(
          color: AppColor.bgElevated,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: TextField(
          controller: _descriptionController,
          minLines: 2,
          maxLines: 2,
          maxLength: 80,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            labelText: context.l10n.listingDescription,
            labelStyle: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 2.h),
            counterStyle: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return BusinessScheduleEditor(
      isAlwaysOpen: _alwaysOpen,
      isGeneralSchedule: _isGeneralSchedule,
      selectedDays: _selectedDays,
      openingTime: _openingTime,
      closingTime: _closingTime,
      onAlwaysOpenChanged: (value) => setState(() => _alwaysOpen = value),
      onScheduleTypeChanged: (value) =>
          setState(() => _isGeneralSchedule = value),
      onDayToggled: _toggleScheduleDay,
      onOpeningChanged: (time) => setState(() => _openingTime = time),
      onClosingChanged: (time) => setState(() => _closingTime = time),
      showLegacyControls: context.read<AppConfig>().useMockBackend,
      title: context.l10n.workHours,
      summaryTitle: context.l10n.scheduleSummary,
    );
  }

  void _toggleScheduleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 5.h, 4.w, 7.h),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          text: _isSaving ? context.l10n.submitting : context.l10n.save,
          height: 52.h,
          onPressed: _save,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: AppTextStyle.primaryText.copyWith(
      color: Colors.white,
      fontSize: 14.sp,
    ),
  );

  Widget _hint(String text) =>
      Text(text, style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp));

  Future<void> _pickImage({required bool isLogo}) async {
    showMediaPickerBottomSheet(
      context: context,
      cropShape: isLogo ? ImageCropShape.square : ImageCropShape.rectangle,
      aspectRatio: isLogo ? 1 : 2000 / 532,
      onImageSelected: (file) {
        if (!mounted) return;
        setState(() {
          if (isLogo) {
            _newLogo = file;
            _logoPath = file.path;
          } else {
            _newBanner = file;
            _bannerPath = file.path;
          }
        });
      },
    );
  }

  Future<void> _selectCity() async {
    final city = await context.goTo<City>(const CityPickerPage());
    if (city != null && mounted) setState(() => _city = city.name);
  }

  Future<void> _selectCategories() async {
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: AppColor.bgSecondary,
      isScrollControlled: true,
      builder: (context) {
        var values = List<String>.of(_categories);
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.categories,
                    style: AppTextStyle.primaryText.copyWith(fontSize: 15.sp),
                  ),
                  8.height,
                  ...CategoryItem.categories
                      .where((item) => item.id != 'catalog')
                      .map(
                        (item) => CheckboxListTile(
                          value: values.contains(item.label),
                          title: Text(
                            item.localizedLabel(context.l10n),
                            style: AppTextStyle.primaryText.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                          activeColor: AppColor.activeColor,
                          onChanged: (selected) => setSheetState(() {
                            if (selected == true) {
                              if (!context.read<AppConfig>().useMockBackend) {
                                values.clear();
                              }
                              values.add(item.label);
                            } else {
                              values.remove(item.label);
                            }
                          }),
                        ),
                      ),
                  AppButton(
                    text: context.l10n.confirm,
                    height: 42.h,
                    onPressed: () => Navigator.of(context).pop(values),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _categories = selected);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final isMock = context.read<AppConfig>().useMockBackend;
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        (isMock && _emailController.text.trim().isEmpty) ||
        _categories.isEmpty) {
      _showMessage(context.l10n.fillRequiredFields);
      return;
    }
    if (isMock &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length < 8) {
      _showMessage(context.l10n.passwordMinLength(8));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await context.read<BusinessRepository>().updateMyStore(
        _draft.copyWith(
          storeName: _nameController.text.trim(),
          slogan: _sloganController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryNames: List.unmodifiable(_categories),
          logoPath: _logoPath,
          bannerPath: _bannerPath,
          city: _city,
          address: _addressController.text.trim(),
          alwaysOpen: _alwaysOpen,
          openDays: List.unmodifiable(_selectedDays),
          openingTime: formatBusinessScheduleTime(_openingTime),
          closingTime: formatBusinessScheduleTime(_closingTime),
          email: _emailController.text.trim(),
          mainPhone: _phoneController.text.trim(),
          additionalPhones: _draft.additionalPhones,
          shortNumber: _shortNumberController.text.trim(),
        ),
      );
      _draft = _draft.copyWith(
        storeName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryNames: List.unmodifiable(_categories),
        mainPhone: _phoneController.text.trim(),
        openingTime: formatBusinessScheduleTime(_openingTime),
        closingTime: formatBusinessScheduleTime(_closingTime),
      );
      if (mounted) context.goBack(updated);
    } on Exception catch (error) {
      if (mounted) _showMessage(context.l10n.profileUpdateFailed('$error'));
    } on StateError catch (error) {
      if (mounted) _showMessage(context.l10n.profileUpdateFailed('$error'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 0, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (metric.length - distance).clamp(0.0, 4.0);
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

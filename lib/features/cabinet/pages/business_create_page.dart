import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/features/cabinet/pages/media_picker_bottom_sheet.dart';
import 'package:vidsell/features/cabinet/widgets/circle_crop_overlay_painter.dart';
import 'package:vidsell/features/discover/models/category_item.dart';
import 'package:vidsell/features/cabinet/pages/business_schedule_page.dart';
import 'package:vidsell/features/discover/models/business_account.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class BusinessCreatePage extends StatefulWidget {
  const BusinessCreatePage({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<BusinessCreatePage> createState() => _BusinessCreatePageState();
}

class _BusinessCreatePageState extends State<BusinessCreatePage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _sloganController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _logoFile;
  File? _bannerFile;
  final List<String> _selectedCategories = [];

  @override
  void dispose() {
    _storeNameController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.h),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 75.h,
            child: Column(
              children: [
                Row(
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
                      context.l10n.stepOneOfThree,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    16.width,
                  ],
                ),
                20.height,
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.bgSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInformationSection(),
              8.height,
              _buildMediaSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildInformationSection() {
    return _buildCard(
      title: context.l10n.generalInfo,
      children: [
        _FloatingTextField(
          controller: _storeNameController,
          label: context.l10n.storeNameLabel,
          isRequired: true,
        ),
        14.height,
        _FloatingTextField(
          controller: _sloganController,
          label: context.l10n.storeSloganLabel,
          isRequired: true,
        ),
        14.height,
        _buildSelectionField(
          title: context.l10n.categories,
          value: _selectedCategories.join(', '),
          hasValue: _selectedCategories.isNotEmpty,
          isRequired: true,
          onTap: _openCategoryPicker,
        ),
        14.height,
        Text.rich(
          TextSpan(
            text: context.l10n.listingDescription,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        14.height,
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildMediaSection() {
    return _buildCard(
      children: [
        Text(
          context.l10n.storeLogo,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        14.height,
        _buildUploadPlaceholder(
          width: 109.w,
          height: 109.w,
          imageFile: _logoFile,
          onTap: () => _pickImage(isLogo: true),
        ),
        14.height,
        Text(
          AppLocalizations.of(context)!.storeLogoHelp,
          style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
        ),
        24.height,
        Text(
          context.l10n.storeBanner,
          style: AppTextStyle.primaryText.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        14.height,
        _buildUploadPlaceholder(
          width: double.infinity,
          height: 85.h,
          imageFile: _bannerFile,
          onTap: () => _pickImage(isLogo: false),
        ),
        14.height,
        Text(
          AppLocalizations.of(context)!.storeBannerHelp,
          style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildCard({String? title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: AppTextStyle.primaryText.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            10.height,
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildSelectionField({
    required String title,
    required String value,
    required bool hasValue,
    required bool isRequired,
    required VoidCallback onTap,
  }) {
    final star = isRequired
        ? const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          )
        : const TextSpan();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        // 45 when empty, a bit higher once categories are chosen
        height: hasValue
            ? _FloatingTextField.activeHeight
            : _FloatingTextField.normalHeight,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.bgElavated,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: hasValue
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: title,
                            style: AppTextStyle.mutedText.copyWith(
                              fontSize: 11.sp,
                            ),
                            children: [star],
                          ),
                        ),
                        2.height,
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          text: title,
                          style: AppTextStyle.mutedText.copyWith(
                            fontSize: 14.sp,
                          ),
                          children: [star],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
            8.width,
            Icon(
              Icons.chevron_right,
              color: AppColor.tertiaryTextColor,
              size: 17.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker() async {
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _BusinessCategoryPicker(initialSelection: _selectedCategories),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedCategories
          ..clear()
          ..addAll(selected);
      });
    }
  }

  Widget _buildDescriptionField() {
    // No fixed height: the field grows and text wraps to the next line
    return TextField(
      controller: _descriptionController,
      minLines: 2,
      maxLines: 3,
      maxLength: 80,
      keyboardType: TextInputType.multiline,
      style: AppTextStyle.primaryText.copyWith(
        color: Colors.white,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hint: Text.rich(
          TextSpan(
            text: context.l10n.businessBenefits,
            style: AppTextStyle.mutedText.copyWith(fontSize: 14.sp),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        counterStyle: AppTextStyle.mutedText.copyWith(fontSize: 10.sp),
        filled: true,
        fillColor: AppColor.bgElavated,
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder({
    required double width,
    required double height,
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: Container(
          width: width,
          height: height,
          color: const Color(0xffE5E7EB),
          child: imageFile == null
              ? Icon(
                  Icons.camera_alt_rounded,
                  color: const Color(0xff737B8A),
                  size: 24.sp,
                )
              : Image.file(imageFile, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isLogo}) async {
    showMediaPickerBottomSheet(
      context: context,
      cropShape: isLogo ? ImageCropShape.square : ImageCropShape.rectangle,
      aspectRatio: isLogo ? 1 : 2000 / 532,
      onImageSelected: (file) {
        if (!mounted) return;
        setState(() {
          if (isLogo) {
            _logoFile = file;
          } else {
            _bannerFile = file;
          }
        });
      },
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: context.l10n.clear,
                color: AppColor.bgElavated,
                height: 48.h,
                onPressed: _clearForm,
              ),
            ),
            8.width,
            Expanded(
              child: AppButton(
                text: 'Davam edin',
                height: 48.h,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _storeNameController.clear();
      _sloganController.clear();
      _descriptionController.clear();
      _logoFile = null;
      _bannerFile = null;
      _selectedCategories.clear();
    });
  }

  Future<void> _continue() async {
    if (_storeNameController.text.trim().isEmpty ||
        _sloganController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.fillRequiredFields)));
      return;
    }
    final account = await context.goTo<BusinessAccount>(
      BusinessSchedulePage(
        draft: BusinessAccountDraft(
          phoneNumber: widget.phoneNumber,
          storeName: _storeNameController.text,
          slogan: _sloganController.text,
          description: _descriptionController.text,
          categoryNames: List.unmodifiable(_selectedCategories),
          logoPath: _logoFile?.path,
          bannerPath: _bannerFile?.path,
        ),
      ),
    );
    if (mounted && account != null) context.goBack(account);
  }
}

/// Text field that is 45 high when empty and unfocused, and a bit higher
/// (small label on top, text below) when focused or filled.
class _FloatingTextField extends StatefulWidget {
  const _FloatingTextField({
    required this.controller,
    required this.label,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String label;
  final bool isRequired;

  static double get normalHeight => 45.h;
  static double get activeHeight => 56.h;

  @override
  State<_FloatingTextField> createState() => _FloatingTextFieldState();
}

class _FloatingTextFieldState extends State<_FloatingTextField> {
  final FocusNode _focusNode = FocusNode();

  bool get _isActive =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    final active = _isActive;
    const star = TextSpan(
      text: ' *',
      style: TextStyle(color: Colors.red),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: active
            ? _FloatingTextField.activeHeight
            : _FloatingTextField.normalHeight,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.bgElavated,
          borderRadius: BorderRadius.circular(10.r),
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
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
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
                // Placeholder only while idle (empty + unfocused)
                hint: active
                    ? null
                    : Text.rich(
                        TextSpan(
                          text: widget.label,
                          style: AppTextStyle.mutedText.copyWith(
                            fontSize: 14.sp,
                          ),
                          children: [if (widget.isRequired) star],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessCategoryPicker extends StatefulWidget {
  const _BusinessCategoryPicker({required this.initialSelection});

  final List<String> initialSelection;

  @override
  State<_BusinessCategoryPicker> createState() =>
      _BusinessCategoryPickerState();
}

class _BusinessCategoryPickerState extends State<_BusinessCategoryPicker> {
  late final Set<String> _selected = widget.initialSelection.toSet();

  List<CategoryItem> get _categories => CategoryItem.categories
      .where((category) => category.id != 'catalog')
      .toList();

  @override
  Widget build(BuildContext context) {
    // Checkboxes are hidden until the first category is selected
    final showCheckboxes = _selected.isNotEmpty;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.82,
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            10.height,
            Container(
              width: 38.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColor.tertiaryTextColor,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 12.w, 14.h),
              child: Row(
                children: [
                  Text(
                    context.l10n.category,
                    style: AppTextStyle.primaryText.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColor.tertiaryTextColor,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => 16.height,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = _selected.contains(category.label);
                  return InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(category.label);
                        } else {
                          _selected.add(category.label);
                        }
                      });
                    },
                    child: Container(
                      height: 48.h,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColor.bgElavated
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColor.bgElavated,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Image.asset(
                              category.iconPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.category_outlined,
                                    color: AppColor.tertiaryTextColor,
                                    size: 18.sp,
                                  ),
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: Text(
                              category.localizedLabel(context.l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.primaryText.copyWith(
                                fontSize: 13.sp,
                                color: const Color(0xffE5E7EB),
                              ),
                            ),
                          ),
                          if (showCheckboxes) ...[
                            _buildCheckbox(selected),
                            4.width,
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, _selected.toList()),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.activeColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      context.l10n.storeCategoryReady,
                      style: AppTextStyle.primaryText.copyWith(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        color: selected ? AppColor.activeColor : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: const Color(0xff465365), width: 1.2),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: selected
          ? Icon(Icons.check, size: 13.sp, color: AppColor.bgSurfaceColor)
          : null,
    );
  }
}

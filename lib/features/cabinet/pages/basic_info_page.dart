import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/cabinet/pages/media_picker_bottom_sheet.dart';
import 'package:vidsell/models/user/user.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class BasicInfoPage extends StatefulWidget {
  final String initialName;
  final String initialAbout;
  final String? initialAvatarUrl;
  final ProfileRepository? profileRepository;

  const BasicInfoPage({
    super.key,
    this.initialName = 'Həsən Məmmədov',
    this.initialAbout = '',
    this.initialAvatarUrl,
    this.profileRepository,
  });

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;

  File? _avatarFile;
  bool _isAvatarRemoved = false;
  bool _isUploading = false;
  late final ProfileRepository _profileRepository;

  static const int _maxAboutLength = 300;
  int _remainingChars = _maxAboutLength;

  @override
  void initState() {
    super.initState();
    _profileRepository =
        widget.profileRepository ?? context.read<ProfileRepository>();
    _nameController = TextEditingController(text: widget.initialName);
    _aboutController = TextEditingController(text: widget.initialAbout);
    _remainingChars = _maxAboutLength - _aboutController.text.length;

    _nameController.addListener(_onFieldChanged);
    _aboutController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _remainingChars = _maxAboutLength - _aboutController.text.length;
    });
  }

  bool get _hasProfileImage {
    if (_isAvatarRemoved) return false;
    return _avatarFile != null ||
        (widget.initialAvatarUrl != null &&
            widget.initialAvatarUrl!.isNotEmpty);
  }

  bool get _isSaveEnabled {
    final isNameValid = _nameController.text.trim().isNotEmpty;
    final isChanged =
        _nameController.text != widget.initialName ||
        _aboutController.text != widget.initialAbout ||
        _avatarFile != null ||
        _isAvatarRemoved;
    return isNameValid && isChanged && !_isUploading;
  }

  void _handleAvatarClick() {
    if (_hasProfileImage) {
      _showAvatarActionBottomSheet();
    } else {
      _openGalleryPicker();
    }
  }

  void _openGalleryPicker() {
    showMediaPickerBottomSheet(
      context: context,
      onImageSelected: (croppedFile) async {
        setState(() {
          _avatarFile = croppedFile;
          _isAvatarRemoved = false;
          _isUploading = true;
        });

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_isSaveEnabled) return;
    setState(() => _isUploading = true);
    try {
      final profile = await _profileRepository.updateProfile(
        name: _nameController.text,
        about: _aboutController.text,
        avatarPath: _avatarFile?.path,
        removeAvatar: _isAvatarRemoved,
      );
      if (mounted) context.goBack<User>(profile);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showAvatarActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.bottomSheetBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.height,
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  title: Text(
                    context.l10n.change,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openGalleryPicker();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 22.sp,
                  ),
                  title: Text(
                    context.l10n.delete,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            context.l10n.profilePhotoDelete,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            context.l10n.profilePhotoDeleteDescription,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 16.w, bottom: 12.h, top: 8.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _avatarFile = null;
                  _isAvatarRemoved = true;
                });
              },
              child: Text(
                context.l10n.delete,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImageProvider;
    if (!_isAvatarRemoved) {
      if (_avatarFile != null) {
        avatarImageProvider = FileImage(_avatarFile!);
      } else if (widget.initialAvatarUrl != null &&
          widget.initialAvatarUrl!.isNotEmpty) {
        avatarImageProvider = NetworkImage(widget.initialAvatarUrl!);
      }
    }

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.basicInfo),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _buildAvatarWithPicker(
                        avatarImageProvider: avatarImageProvider,
                        onTap: _handleAvatarClick,
                      ),
                    ),
                    24.height,
                    _buildNameField(),
                    16.height,
                    _buildAboutField(),
                    8.height,
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        context.l10n.aboutYou,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithPicker({
    required ImageProvider? avatarImageProvider,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 42.r,
            backgroundColor: const Color(0xFF222B38),
            backgroundImage: avatarImageProvider,
            child: avatarImageProvider == null
                ? Icon(Icons.person, color: Colors.white38, size: 52.sp)
                : null,
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.activeColor,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: AppColor.activeColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primaryColor, width: 2.w),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: Colors.grey.shade500,
          size: 20.sp,
        ),
        filled: true,
        fillColor: AppColor.bgSurfaceColor,
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

  Widget _buildAboutField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        children: [
          TextField(
            controller: _aboutController,
            maxLines: 4,
            maxLength: _maxAboutLength,
            inputFormatters: [
              LengthLimitingTextInputFormatter(_maxAboutLength),
            ],
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: context.l10n.accountAbout,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.only(right: 42.w, bottom: 8.h),
              border: InputBorder.none,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Text(
              '$_remainingChars',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSaveButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: const BoxDecoration(color: AppColor.primaryColor),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: _isSaveEnabled ? _saveProfile : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.activeColor,
            disabledBackgroundColor: const Color(0xFF222B38),
            disabledForegroundColor: Colors.grey.shade600,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            context.l10n.save,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

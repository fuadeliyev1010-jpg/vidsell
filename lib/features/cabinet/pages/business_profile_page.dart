import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_button.dart';
import 'package:vidsell/core/widgets/bottom_navigation.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';

class BusinessProfilePage extends StatelessWidget {
  const BusinessProfilePage({super.key, required Store account})
    : _publicStore = account,
      _ownerStore = null;

  const BusinessProfilePage.owner({super.key, required MyStore store})
    : _ownerStore = store,
      _publicStore = null;

  const BusinessProfilePage.public({super.key, required Store store})
    : _publicStore = store,
      _ownerStore = null;

  final MyStore? _ownerStore;
  final Store? _publicStore;

  String get _name => _ownerStore?.displayName ?? _publicStore!.displayName;
  String? get _logo => _ownerStore?.logoUrl ?? _publicStore!.logoUrl;
  String get _description =>
      _ownerStore?.description ?? _publicStore!.description;
  String get _phone => _ownerStore?.phoneDisplay ?? _publicStore!.phoneDisplay;
  String get _workingHours =>
      _ownerStore?.workingHoursDisplay ?? _publicStore!.workingHoursDisplay;
  bool get _isOpen => _ownerStore?.isOpen ?? _publicStore!.isOpen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.storeProfile),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 16.h),
                children: [
                  _buildStoreHeader(),
                  46.height,
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
                    child: Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_ownerStore != null) _buildStatus(context),
                  14.height,
                  _buildContactCard(context),
                  if (_description.trim().isNotEmpty) ...[
                    8.height,
                    _buildAboutCard(context),
                  ],
                ],
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentNavIndex: 4),
    );
  }

  Widget _buildStoreHeader() {
    return SizedBox(
      height: 94.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFF252D3A))),
          Positioned(
            left: 12.w,
            top: 56.h,
            child: Container(
              width: 74.r,
              height: 74.r,
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                border: Border.all(color: AppColor.primaryColor, width: 3.r),
              ),
              child: _buildStoreImage(_logo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreImage(String? path) {
    if (path == null || path.trim().isEmpty) {
      return const ColoredBox(color: Color(0xFF252D3A));
    }
    final uri = Uri.tryParse(path);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    return isNetwork
        ? Image.network(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);
  }

  Widget _buildStatus(BuildContext context) {
    final ownerStore = _ownerStore;
    if (ownerStore == null) return const SizedBox.shrink();
    final status = ownerStore.statusDisplay;
    final label = switch (status) {
      'APPLICATION' => context.l10n.storeStatusApplication,
      'ACTIVE' => context.l10n.storeApproved,
      'INACTIVE' => context.l10n.storeStatusInactive,
      'SUSPENDED' => context.l10n.storeStatusSuspended,
      'REJECTED' => context.l10n.storeStatusRejected,
      _ => status,
    };
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Text(
        ownerStore.rejectionReason?.trim().isNotEmpty == true
            ? '$label: ${ownerStore.rejectionReason}'
            : label,
        style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          if (_phone.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.call_outlined,
              context.l10n.phone,
              _phone,
            ),
          if (_workingHours.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.access_time,
              context.l10n.workHours,
              _workingHours,
            ),
          _buildInfoRow(
            context,
            Icons.storefront_outlined,
            context.l10n.storeProfile,
            _isOpen ? context.l10n.openNow : context.l10n.storeClosed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 52.h),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Icon(icon, color: AppColor.activeColor, size: 20.sp),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
                  ),
                  2.height,
                  Text(
                    value,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.accountAbout,
            style: AppTextStyle.mutedText.copyWith(fontSize: 12.sp),
          ),
          3.height,
          Text(
            _description,
            style: AppTextStyle.primaryText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.h),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          text: context.l10n.close,
          icon: Icons.arrow_back,
          height: 52.h,
          onPressed: Navigator.of(context).pop,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/cabinet/pages/basic_info_page.dart';
import 'package:vidsell/models/user/user.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/widgets/cabin_appbar.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileRepository? profileRepository;

  const EditProfilePage({super.key, this.profileRepository});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileRepository _profileRepository;
  late Future<User> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileRepository =
        widget.profileRepository ?? context.read<ProfileRepository>();
    _profileFuture = _profileRepository.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: CabinAppbar(title: context.l10n.profileEdit),
      body: SafeArea(
        child: FutureBuilder<User>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    snapshot.error.toString(),
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final profile = snapshot.data;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  _buildBasicInfoRow(context, profile),
                  16.height,
                  _buildAccountSettingsCard(context, profile),
                  16.height,
                  _buildProfileViewsCard(context),
                  16.height,
                  _buildProfileManagementCard(context),
                  24.height,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard(BuildContext context, User? profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/ic_baseline_messages.svg',
            title: context.l10n.email,
            subtitle: profile?.email.isNotEmpty == true
                ? profile!.email
                : context.l10n.profileEmailMissing,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/phone_icon.svg',
            title: context.l10n.phone,
            subtitle: profile?.phone,
            badge: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColor.successBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColor.successLight, width: 1.2),
              ),
              child: Text(
                context.l10n.listingVerified,
                style: TextStyle(
                  color: AppColor.successLight,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/solar_lock-linear.svg',
            title: context.l10n.changePassword,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoRow(BuildContext context, User? profile) {
    return InkWell(
      onTap: () async {
        final currentProfile = await _profileRepository.fetchProfile();
        if (!context.mounted) return;
        final updatedProfile = await context.goTo<User>(
          BasicInfoPage(
            initialName: currentProfile.name,
            initialAbout: currentProfile.about,
            initialAvatarUrl: currentProfile.avatarUrl,
            profileRepository: _profileRepository,
          ),
        );
        if (updatedProfile != null && mounted) {
          setState(() => _profileFuture = Future.value(updatedProfile));
        }
      },
      child: Container(
        height: 68.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18.r),
        ),

        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColor.surfaceHighlight,
              child: SvgPicture.asset(
                'assets/icons/profile-2.svg',
                width: 20.w,
                height: 20.h,
              ),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name.isNotEmpty == true
                        ? profile!.name
                        : context.l10n.userProfile,
                    style: AppTextStyle.primaryText.copyWith(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  2.height,
                  Text(
                    context.l10n.profileSummary,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileViewsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            iconPath: 'assets/icons/solar_eye-linear.svg',
            title: context.l10n.profileViews,
            subtitle: context.l10n.howOthersSeeProfile,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileManagementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            iconPath: 'assets/icons/mynaui_globe.svg',
            title: context.l10n.personalLink,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/solar_link-bold.svg',
            title: context.l10n.socialLinks,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/phone_icon.svg',
            title: context.l10n.additionalPhone,
            subtitle: context.l10n.contactDetails,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/time_icon.svg',
            title: context.l10n.workHours,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/solar_camera-linear.svg',
            title: context.l10n.photoGallery,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/proicons_photo.svg',
            title: context.l10n.banner,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/mynaui_message-dots.svg',
            title: context.l10n.welcomeMessages,
            subtitle: context.l10n.greetNewCustomers,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingRow(
            iconPath: 'assets/icons/delete_icon.svg',
            title: context.l10n.accountDelete,
            titleColor: const Color(0xFFFF5A5A),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFFF5A5A),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String iconPath,
    required String title,
    String? subtitle,
    Widget? badge,
    required Widget trailing,
    Color titleColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 20.w, height: 20.h),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.primaryText.copyWith(
                      color: titleColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    4.height,
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null) ...[badge, 8.width],
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 14.w),
      child: Divider(
        color: const Color(0xFF2A3542),
        height: 1.h,
        thickness: 1.h,
      ),
    );
  }
}

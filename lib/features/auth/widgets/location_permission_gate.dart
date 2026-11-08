import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/services/location_permission_service.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class LocationPermissionGate extends StatefulWidget {
  final Widget child;

  const LocationPermissionGate({super.key, required this.child});

  @override
  State<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends State<LocationPermissionGate> {
  final LocationPermissionService _service = LocationPermissionService();
  bool _isChecking = true;
  bool _shouldShowPermissionPrompt = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final alreadyRequested = await _service.hasRequested();
    if (!mounted) return;

    if (alreadyRequested) {
      setState(() {
        _isChecking = false;
        _shouldShowPermissionPrompt = false;
      });
      unawaited(_loadCurrentLocation());
    } else {
      setState(() {
        _isChecking = false;
        _shouldShowPermissionPrompt = true;
      });
    }
  }

  Future<void> _handleAllow() async {
    await _service.requestPermission();
    if (!mounted) return;
    setState(() => _shouldShowPermissionPrompt = false);
    unawaited(_loadCurrentLocation());
  }

  Future<void> _loadCurrentLocation() async {
    try {
      await _service.getCurrentLocation();
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'location',
          context: ErrorDescription(
            'while reading the current device location',
          ),
        ),
      );
    }
  }

  Future<void> _handleSkip() async {
    await _service.markRequested();
    if (!mounted) return;
    setState(() => _shouldShowPermissionPrompt = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.activeColor),
        ),
      );
    }

    if (!_shouldShowPermissionPrompt) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Glowing Cyan Location Pin Graphic
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColor.activeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.activeColor.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.activeColor.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColor.activeColor,
                    size: 48.sp,
                  ),
                ),
              ),
              32.height,

              // Title
              Text(
                context.l10n.locationPermissionTitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              12.height,

              // Explanation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  context.l10n.locationPermissionDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.primaryText.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.5.sp,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(),

              // Primary "İcazə ver" Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _handleAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.allow,
                    style: AppTextStyle.primaryText.copyWith(
                      color: const Color(0xFF0F1115),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              12.height,

              // Secondary "Daha sonra" Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    context.l10n.later,
                    style: AppTextStyle.primaryText.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }
}

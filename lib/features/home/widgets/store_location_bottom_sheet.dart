import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/widgets/map_view.dart';
import 'package:vidsell/models/product/product.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class StoreLocationBottomSheet extends StatelessWidget {
  final String storeName;
  final String location;
  final String category;

  const StoreLocationBottomSheet({
    super.key,
    required this.storeName,
    required this.location,
    this.category = 'Elektronik',
  });

  static Future<void> show(
    BuildContext context, {
    required String storeName,
    required String location,
    String category = 'Elektronik',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoreLocationBottomSheet(
        storeName: storeName,
        location: location,
        category: category,
      ),
    );
  }

  Future<void> _openExternalMap(BuildContext context) async {
    final query = Uri.encodeComponent(location);
    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    try {
      final launched = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.mapUnavailable)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.mapUnavailable)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate a single pin for the store location
    final storeProduct = Product(
      id: 'store-location',
      imageUrls: const ['assets/images/vidsell_logo.png'],
      price: 0,
      currency: '',
      title: location,
      sellerName: storeName,
      city: location,
      brand: category,
      latitude: 40.9903,
      longitude: 29.0293,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: const Color(0xFF263042), width: 0.8),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3B4656),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          16.height,

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColor.activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColor.activeColor,
                      size: 20.sp,
                    ),
                  ),
                  12.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.storeAddress,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      2.height,
                      Text(
                        storeName,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.secondaryTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E2533),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          16.height,

          // Map View with store location pin
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: ListingMapView(
              listings: [storeProduct],
              height: 190,
              showExpandButton: true,
              initialCenter: const LatLng(40.9903, 29.0293),
              initialZoom: 14.8,
            ),
          ),
          16.height,

          // Address Card
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2230),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF2A364A), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF242F42),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: AppColor.activeColor,
                    size: 18.sp,
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: AppTextStyle.primaryText.copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      3.height,
                      Text(
                        context.l10n.istanbulDistrictAddress,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.secondaryTextColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          16.height,

          // Open in Google Maps navigation button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => _openExternalMap(context),
              icon: Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                context.l10n.navigateGoogleMaps,
                style: AppTextStyle.primaryText.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

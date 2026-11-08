import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/utils/product_localization.dart';
import 'package:vidsell/features/home/widgets/product_details_sheet.dart';
import 'package:vidsell/features/messages/utils/open_seller_chat.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/product/product.dart';

class MapListingCard extends StatelessWidget {
  const MapListingCard({
    super.key,
    required this.listing,
    required this.onCall,
    required this.onDirections,
    this.onTap,
  });

  final Product listing;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback? onTap;

  void _showDetails(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        listing: listing,
        onMessage: (message) {
          Navigator.of(context).pop();
          openSellerChat(
            context,
            listing,
            initialMessage: message.isEmpty ? null : message,
          );
        },
        price: listing.formattedPrice,
        title: listing.title,
        city: listing.localizedLocation(context.l10n),
        subCategory: listing.brand,
      ),
    );
  }

  Widget _imageFallback(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFD9DADD),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Colors.black38,
        size: size * 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final imagePath = listing.imageUrls.isEmpty ? '' : listing.imageUrls.first;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.activeColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _showDetails(context),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColor.bgSurfaceColor,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    listing.brand.isEmpty
                        ? 'T'
                        : listing.brand[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColor.activeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                10.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              listing.sellerName?.isNotEmpty == true
                                  ? listing.sellerName!
                                  : 'TechZone',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.primaryText.copyWith(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (listing.isVip) ...[
                            6.width,
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColor.activeColor,
                              size: 13.sp,
                            ),
                            Text(
                              ' VIP',
                              style: AppTextStyle.primaryText.copyWith(
                                color: AppColor.activeColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      2.height,
                      Text(
                        '${listing.brand} · ${listing.localizedLocation(localizations)} · '
                        '${localizations.openUntil('22:00')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.primaryText.copyWith(
                          color: AppColor.tertiaryTextColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          8.height,
          InkWell(
            onTap: () => _showDetails(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: AppColor.bgSurfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imagePath.startsWith('http')
                        ? Image.network(
                            imagePath,
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _imageFallback(40.w),
                          )
                        : Image.asset(
                            imagePath,
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _imageFallback(40.w),
                          ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        2.height,
                        Text(
                          localizations.listingStockLocation(
                            listing.localizedLocation(localizations),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.primaryText.copyWith(
                            color: AppColor.tertiaryTextColor,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  5.width,
                  Text(
                    listing.formattedPrice,
                    style: AppTextStyle.primaryText.copyWith(
                      color: AppColor.activeColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          7.height,
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  iconPath: 'assets/icons/phone_icon.svg',
                  iconColor: Colors.white,
                  bgColor: AppColor.activeColor,
                  label: context.l10n.call,
                  filled: true,
                  onTap: onCall,
                ),
              ),
              8.width,
              Expanded(
                child: _buildActionButton(
                  iconPath: 'assets/icons/direction.svg',
                  iconColor: AppColor.activeColor,
                  bgColor: Colors.transparent,
                  label: context.l10n.directions,
                  filled: false,
                  onTap: onDirections,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconPath,
    required String label,
    required bool filled,
    required VoidCallback onTap,
    required Color iconColor,
    required Color bgColor,
  }) {
    return SizedBox(
      height: 38.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: SvgPicture.asset(iconPath, width: 16.w, height: 16.w),
        label: Text(label, style: TextStyle(fontSize: 13.sp)),
        style: OutlinedButton.styleFrom(
          foregroundColor: iconColor,
          backgroundColor: bgColor,
          side: BorderSide(color: AppColor.activeColor, width: filled ? 0 : 1),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

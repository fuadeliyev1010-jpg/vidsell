import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/product/product.dart';

class InactiveListingCard extends StatelessWidget {
  final Product listing;
  final bool isSelected;
  final VoidCallback onTap;

  const InactiveListingCard({
    super.key,
    required this.listing,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final updatedAt = listing.updatedAt ?? listing.createdAt;
    final hoursAgo = updatedAt == null
        ? 1
        : DateTime.now().difference(updatedAt).inHours.clamp(1, 9999).toInt();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165.w,
        height: 235.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.bgSurfaceColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _listingImage()),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColor.activeColor
                      : Colors.black.withValues(alpha: 0.3),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.white, width: 1.5.w),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      )
                    : null,
              ),
            ),
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${listing.price.toStringAsFixed(2)} ${listing.currency}',
                      style: TextStyle(
                        color: AppColor.activeColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  4.height,
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  6.height,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.city ?? context.l10n.cityIstanbul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                      4.width,
                      Text(
                        context.l10n.hoursAgo(hoursAgo),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingImage() {
    final path = listing.imageUrls.isEmpty ? '' : listing.imageUrls.first;
    if (path.isEmpty) {
      return const ColoredBox(color: AppColor.bgSurfaceColor);
    }

    final ImageProvider image =
        path.startsWith('http://') || path.startsWith('https://')
        ? NetworkImage(path)
        : path.startsWith('assets/')
        ? AssetImage(path)
        : FileImage(File(path));
    return Image(
      image: image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: AppColor.bgSurfaceColor),
    );
  }
}

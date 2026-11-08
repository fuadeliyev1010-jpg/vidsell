import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/services/location_permission_service.dart';
import 'package:vidsell/core/utils/call_seller.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/search_text_field.dart';
import 'package:vidsell/features/discover/models/listing_filter.dart';
import 'package:vidsell/features/discover/pages/filter_page.dart';
import 'package:vidsell/features/discover/utils/product_localization.dart';
import 'package:vidsell/features/discover/widgets/map_listing_card.dart';
import 'package:vidsell/features/home/widgets/product_details_sheet.dart';
import 'package:vidsell/features/messages/utils/open_seller_chat.dart';
import 'package:vidsell/models/product/map_pin.dart';
import 'package:vidsell/models/product/product.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

TileLayer _openStreetMapTiles() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'az.vidsell.app',
  maxNativeZoom: 19,
);

/// Shared placeholder used when an asset image fails to decode.
Widget _imageFallback(double size) {
  return Container(
    width: size,
    height: size,
    color: const Color(0xFF2A313B),
    child: Icon(
      Icons.image_not_supported_outlined,
      size: size * 0.45,
      color: Colors.white38,
    ),
  );
}

MapPin? _mapPinFor(Product product, List<MapPin>? mapPins) {
  if (mapPins != null) {
    for (final pin in mapPins) {
      if (pin.id == product.id) return pin;
    }
    return null;
  }
  final latitude = product.latitude;
  final longitude = product.longitude;
  if (latitude == null || longitude == null) return null;
  return MapPin(id: product.id, latitude: latitude, longitude: longitude);
}

Widget _productImage(Product product, double size) {
  final imagePath = product.imageUrls.isEmpty ? '' : product.imageUrls.first;
  final fallback = _imageFallback(size);
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
  return Image.asset(
    imagePath,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => fallback,
  );
}

class ListingMapView extends StatefulWidget {
  final List<Product> listings;
  final List<MapPin>? mapPins;
  final ValueChanged<Product>? onListingSelected;
  final double height;
  final bool showExpandButton;
  final LatLng initialCenter;
  final double initialZoom;

  const ListingMapView({
    super.key,
    required this.listings,
    this.mapPins,
    this.onListingSelected,
    this.height = 165,
    this.showExpandButton = true,
    this.initialCenter = const LatLng(41.0082, 28.9784),
    this.initialZoom = 11.2,
  });

  @override
  State<ListingMapView> createState() => _ListingMapViewState();
}

class _ListingMapViewState extends State<ListingMapView> {
  int? _selectedPinIndex;

  List<MapPin?> get _resolvedPins => widget.listings
      .map((item) => _mapPinFor(item, widget.mapPins))
      .toList(growable: false);

  void _openFullScreenMap(BuildContext context) {
    context.goTo(
      FullScreenMapPage(
        listings: widget.listings,
        mapPins: widget.mapPins,
        initialSelectedIndex: _selectedPinIndex,
        initialCenter: widget.initialCenter,
      ),
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pins = _resolvedPins;
    return Container(
      height: widget.height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.bgSurfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: widget.initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                _openStreetMapTiles(),
                MarkerLayer(
                  markers: [
                    for (var i = 0; i < widget.listings.length; i++)
                      if (pins[i] != null)
                        Marker(
                          point: LatLng(pins[i]!.latitude, pins[i]!.longitude),
                          width: 40.w,
                          height: 44.h,
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPinIndex = i);
                              widget.onListingSelected?.call(
                                widget.listings[i],
                              );
                            },
                            child: Icon(
                              Icons.location_on,
                              color: _selectedPinIndex == i
                                  ? AppColor.activeColor
                                  : const Color(0xFF49B6E8),
                              size: 38.sp,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 5),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),

          // District label
          Positioned(
            left: 12.w,
            bottom: 8.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0F141E).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                context.l10n.cityIstanbul,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          // Selected Item Floating Callout Banner (when a pin is tapped)
          if (_selectedPinIndex != null &&
              _selectedPinIndex! < widget.listings.length &&
              pins[_selectedPinIndex!] != null)
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 8.h,
              child: _buildSelectedCallout(widget.listings[_selectedPinIndex!]),
            ),

          // Expand / Fullscreen map button
          if (widget.showExpandButton)
            Positioned(
              right: 8.w,
              top: 8.h,
              child: InkWell(
                onTap: () => _openFullScreenMap(context),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10141D).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: AppColor.activeColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedCallout(Product item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ProductDetailsSheet(
              listing: item,
              onMessage: (message) {
                Navigator.of(context).pop();
                openSellerChat(
                  context,
                  item,
                  initialMessage: message.isEmpty ? null : message,
                );
              },
              price: item.formattedPrice,
              title: item.title,
              city: item.localizedLocation(context.l10n),
              subCategory: item.brand,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF10141D).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColor.activeColor.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: _productImage(item, 36.w),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    2.height,
                    Text(
                      '${item.formattedPrice} • ${item.localizedLocation(context.l10n)}',
                      style: AppTextStyle.primaryText.copyWith(
                        color: AppColor.activeColor,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 12.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fullscreen OpenStreetMap view with listing prices positioned at coordinates.
class FullScreenMapPage extends StatefulWidget {
  final List<Product> listings;
  final List<MapPin>? mapPins;
  final int? initialSelectedIndex;
  final LatLng initialCenter;
  final double initialZoom;

  const FullScreenMapPage({
    super.key,
    required this.listings,
    this.mapPins,
    this.initialSelectedIndex,
    this.initialCenter = const LatLng(41.0082, 28.9784),
    this.initialZoom = 12.0,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  final MapController _mapController = MapController();
  late int _selectedIndex;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  ListingFilter? _activeFilter;
  bool _vipOnly = false;
  bool _openNowOnly = false;
  bool _nearestFirst = false;
  bool _showListings = false;
  bool _mapReady = false;
  LatLng? _userLocation = LocationPermissionService.lastKnownLocation;

  MapPin? _pinFor(Product product) => _mapPinFor(product, widget.mapPins);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex ?? 0;
    _searchController = TextEditingController(text: '');
    _loadUserLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    final hadCachedLocation = _userLocation != null;
    try {
      final location = await LocationPermissionService().getCurrentLocation();
      if (!mounted) return;
      setState(() => _userLocation = location);
      if (_mapReady && !_showListings && location != null) {
        _mapController.move(location, 12.0);
      } else if (_mapReady && !_showListings && hadCachedLocation) {
        _mapController.move(widget.initialCenter, widget.initialZoom);
      }
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

  List<int> get _visibleListingIndexes {
    final query = _searchQuery.toLowerCase();
    final indexes = <int>[];
    for (var index = 0; index < widget.listings.length; index++) {
      final item = widget.listings[index];
      final pin = _pinFor(item);
      if (pin == null) continue;
      if (_vipOnly && !item.isVip) continue;
      if (query.isNotEmpty &&
          !item.title.toLowerCase().contains(query) &&
          !item.brand.toLowerCase().contains(query)) {
        continue;
      }
      if (_activeFilter?.minPrice != null &&
          item.price < _activeFilter!.minPrice!) {
        continue;
      }
      if (_activeFilter?.maxPrice != null &&
          item.price > _activeFilter!.maxPrice!) {
        continue;
      }
      if (_activeFilter?.cityName != null &&
          !(item.city ?? '').toLowerCase().contains(
            _activeFilter!.cityName!.toLowerCase(),
          )) {
        continue;
      }
      indexes.add(index);
    }
    if (_nearestFirst) {
      indexes.sort((first, second) {
        final a = widget.listings[first];
        final b = widget.listings[second];
        final pinA = _pinFor(a)!;
        final pinB = _pinFor(b)!;
        final center = _userLocation ?? widget.initialCenter;
        final distanceA =
            (pinA.latitude - center.latitude).abs() +
            (pinA.longitude - center.longitude).abs();
        final distanceB =
            (pinB.latitude - center.latitude).abs() +
            (pinB.longitude - center.longitude).abs();
        return distanceA.compareTo(distanceB);
      });
    }
    return indexes;
  }

  /// The index that should be shown as selected given the visible list.
  int _effectiveSelected(List<int> visible) {
    if (visible.contains(_selectedIndex)) return _selectedIndex;
    return visible.isNotEmpty ? visible.first : -1;
  }

  List<Marker> _buildMarkers(List<int> visible, int selected) => [
    for (final index in visible)
      Marker(
        point: LatLng(
          _pinFor(widget.listings[index])!.latitude,
          _pinFor(widget.listings[index])!.longitude,
        ),
        width: 132.w,
        height: 42.h,
        child: GestureDetector(
          onTap: () => _selectItem(index),
          child: _buildPriceMarker(
            widget.listings[index],
            selected: index == selected,
          ),
        ),
      ),
  ];

  Widget _buildPriceMarker(Product item, {required bool selected}) {
    final foreground = selected ? const Color(0xFF07131B) : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected ? AppColor.activeColor : const Color(0xFF171C24),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: selected ? Colors.white : AppColor.activeColor,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.isVip) ...[
            Icon(
              Icons.workspace_premium_rounded,
              color: foreground,
              size: 13.sp,
            ),
            3.width,
          ],
          Flexible(
            child: Text(
              _formatPrice(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Updates state and rebuilds the markers.
  void _update(VoidCallback fn) {
    setState(fn);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _selectItem(int index) {
    setState(() => _selectedIndex = index);
    final item = widget.listings[index];
    final pin = _pinFor(item)!;
    if (_mapReady) {
      _mapController.move(LatLng(pin.latitude, pin.longitude), 14.0);
    }
  }

  Future<void> _openFilter() async {
    final filter = await context.goTo<ListingFilter>(const FilterPage());
    if (filter != null && mounted) {
      _update(() => _activeFilter = filter);
    }
  }

  Future<void> _openDirections(Product item) async {
    final pin = _pinFor(item)!;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${pin.latitude},${pin.longitude}',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.mapRouteError)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.mapRouteError)));
      }
    }
  }

  String _formatPrice(Product item) => item.formattedPrice;

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final visibleIndexes = _visibleListingIndexes;
    final selectedIndex = _effectiveSelected(visibleIndexes);
    final selectedItem = selectedIndex == -1
        ? null
        : widget.listings[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Stack(
          children: [
            if (!_showListings)
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation ?? widget.initialCenter,
                    initialZoom: widget.initialZoom,
                    onMapReady: () {
                      _mapReady = true;
                      final location = _userLocation;
                      if (location != null) {
                        _mapController.move(location, 12.0);
                      }
                    },
                  ),
                  children: [
                    _openStreetMapTiles(),
                    MarkerLayer(
                      markers: [
                        ..._buildMarkers(visibleIndexes, selectedIndex),
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 30.w,
                            height: 30.h,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4285F4,
                                ).withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 11.w,
                                  height: 11.h,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4285F4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            Positioned(left: 0, right: 0, top: 0, child: _buildSearchBar()),
            Positioned(
              left: 8.w,
              right: 0,
              top: 64.h,
              child: _buildMapFilters(visibleIndexes.length),
            ),

            if (_showListings)
              Positioned.fill(
                top: 110.h,
                child: visibleIndexes.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.noResults,
                          style: AppTextStyle.primaryText.copyWith(
                            color: AppColor.secondaryTextColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 16.h),
                        itemCount: visibleIndexes.length,
                        separatorBuilder: (_, _) => 14.height,
                        itemBuilder: (context, index) {
                          final itemIndex = visibleIndexes[index];
                          final item = widget.listings[itemIndex];
                          return MapListingCard(
                            listing: item,
                            onCall: () => callSeller(context, item.sellerPhone),
                            onDirections: () => _openDirections(item),
                            onTap: () => _showDetails(item),
                          );
                        },
                      ),
              ),

            if (!_showListings)
              Positioned(
                right: 16.w,
                bottom: selectedItem == null ? 24.h : 212.h,
                child: Column(
                  children: [
                    _buildMapControl(
                      icon: Icons.menu_rounded,
                      onTap: () => setState(() => _showListings = true),
                    ),
                    8.height,
                    _buildMapControl(
                      icon: Icons.my_location_rounded,
                      onTap: () {
                        if (_mapReady) {
                          _mapController.move(
                            _userLocation ?? widget.initialCenter,
                            12.0,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (!_showListings && selectedItem != null)
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: _buildSelectedListingCard(selectedItem),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56.h,
      decoration: const BoxDecoration(color: Color(0xFF101216)),
      child: Row(
        children: [
          InkWell(
            onTap: _showListings
                ? () => setState(() => _showListings = false)
                : context.goBack,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(7.w),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColor.mutedColor,
                size: 24.sp,
              ),
            ),
          ),
          5.width,
          Expanded(
            child: SearchTextField(
              controller: _searchController,
              onChanged: (value) => _update(() => _searchQuery = value.trim()),
            ),
          ),
          5.width,
          InkWell(
            onTap: _openFilter,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(7.w),
              child: SvgPicture.asset(
                'assets/images/menu.svg',
                width: 26.sp,
                height: 26.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFilters(int visibleCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          _buildFilterChip(
            'VIP ($visibleCount)',
            selected: _vipOnly,
            onTap: () => _update(() => _vipOnly = !_vipOnly),
            vip: true,
          ),
          7.width,
          _buildFilterChip(
            'Open now',
            selected: _openNowOnly,
            onTap: () => _update(() => _openNowOnly = !_openNowOnly),
          ),
          7.width,
          _buildFilterChip(
            'Nearest',
            selected: _nearestFirst,
            onTap: () => _update(() => _nearestFirst = !_nearestFirst),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
    bool vip = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 33.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColor.bgSecondary,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColor.activeColor : AppColor.bgSecondary,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vip) ...[
              Icon(
                Icons.workspace_premium_rounded,
                color: AppColor.activeColor,
                size: 13.sp,
              ),
              3.width,
            ],
            Text(
              label,
              style: AppTextStyle.primaryText.copyWith(
                color: selected
                    ? AppColor.activeColor
                    : AppColor.tertiaryTextColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColor.bgSecondary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  void _showDetails(Product item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        listing: item,
        onMessage: (message) {
          Navigator.of(context).pop();
          openSellerChat(
            context,
            item,
            initialMessage: message.isEmpty ? null : message,
          );
        },
        price: item.formattedPrice,
        title: item.title,
        city: item.localizedLocation(context.l10n),
        subCategory: item.brand,
      ),
    );
  }

  Widget _buildSelectedListingCard(Product item) {
    return MapListingCard(
      listing: item,
      onCall: () => callSeller(context, item.sellerPhone),
      onDirections: () => _openDirections(item),
      onTap: () => _showDetails(item),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/utils/video_url_resolver.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/discover/utils/video_slot_pool.dart';
import 'package:vidsell/features/discover/utils/product_localization.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/home/widgets/product_details_sheet.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/product/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final Object? playbackGroup;
  final String? videoUrl;
  final String? hlsUrl;
  final String? rawUrl;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
    this.playbackGroup,
    this.videoUrl,
    this.hlsUrl,
    this.rawUrl,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite = widget.product.isFavorite;
  VideoPlayerController? _controller;
  bool _videoFailed = false;
  double _visibleFraction = 0;

  Product get _product => widget.product;

  String? get _videoUrl =>
      VideoUrlResolver.selectPlaybackUrl(
        hlsUrl: widget.hlsUrl,
        rawUrl: widget.rawUrl,
      ) ??
      widget.videoUrl;

  String get _imagePath =>
      _product.imageUrls.isEmpty ? '' : _product.imageUrls.first;

  String get _price => _formattedPrice(_product);

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIsFavorite = oldWidget.product.isFavorite;
    final newIsFavorite = widget.product.isFavorite;
    if (oldIsFavorite != newIsFavorite) {
      _isFavorite = newIsFavorite;
    }
    if (_videoUrlFor(oldWidget) != _videoUrl ||
        oldWidget.playbackGroup != widget.playbackGroup) {
      VideoSlotPool.instance.release(this, deactivate: false);
      _disposeController();
      if (_videoUrlFor(oldWidget) != _videoUrl) {
        _videoFailed = false;
      }
      _registerVisibleCandidate(_visibleFraction);
    }
  }

  static String? _videoUrlFor(ProductCard card) =>
      VideoUrlResolver.selectPlaybackUrl(
        hlsUrl: card.hlsUrl,
        rawUrl: card.rawUrl,
      ) ??
      card.videoUrl;

  @override
  void dispose() {
    VideoSlotPool.instance.release(this, deactivate: false);
    _disposeController();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    _visibleFraction = info.visibleFraction;
    _registerVisibleCandidate(info.visibleFraction);
  }

  void _registerVisibleCandidate(double visibleFraction) {
    final videoUrl = _videoUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) {
      VideoSlotPool.instance.release(this);
      return;
    }
    VideoSlotPool.instance.updateVisibility(
      this,
      visibleFraction,
      playbackGroup: widget.playbackGroup,
      centerDistance: _distanceFromViewportCenter,
      onActivate: _activateVideo,
      onDeactivate: _deactivateVideo,
    );
  }

  double _distanceFromViewportCenter() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return double.infinity;
    }
    final cardCenter = renderObject.localToGlobal(
      Offset(0, renderObject.size.height / 2),
    );
    return (cardCenter.dy - MediaQuery.sizeOf(context).height / 2).abs();
  }

  void _activateVideo() {
    if (!mounted || _controller != null || _videoFailed) return;
    _initializeVideo();
    setState(() {});
  }

  void _deactivateVideo() {
    if (!mounted || _controller == null) return;
    _disposeController();
    setState(() {});
  }

  void _initializeVideo() {
    final videoUrl = _videoUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    final uri = Uri.tryParse(videoUrl);
    late final VideoPlayerController controller;
    if (videoUrl.startsWith('assets/')) {
      controller = VideoPlayerController.asset(videoUrl);
    } else if (videoUrl.startsWith('/')) {
      controller = VideoPlayerController.file(File(videoUrl));
    } else {
      if (uri?.scheme == 'file') {
        controller = VideoPlayerController.file(File.fromUri(uri!));
      } else {
        final networkUri = VideoUrlResolver.resolveNetworkUrl(videoUrl);
        if (networkUri == null) {
          _videoFailed = true;
          return;
        }
        controller = VideoPlayerController.networkUrl(networkUri);
      }
    }
    _controller = controller;
    controller.addListener(_onControllerChanged);
    unawaited(_loadVideo(controller));
  }

  void _onControllerChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.hasError) return;
    _showVideoError(controller);
  }

  Future<void> _loadVideo(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      if (!mounted || controller != _controller) return;
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      _showVideoError(controller, error: error);
    }
  }

  void _showVideoError(VideoPlayerController controller, {Object? error}) {
    if (!mounted || controller != _controller || _videoFailed) return;
    if (kDebugMode) {
      debugPrint(
        'ProductCard video error: '
        '${controller.value.errorDescription}; caught: $error',
      );
    }
    setState(() => _videoFailed = true);
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_onControllerChanged);
      unawaited(controller.dispose());
    }
  }

  void _retryVideo() {
    if (!_videoFailed) return;
    _disposeController();
    setState(() => _videoFailed = false);
    _initializeVideo();
  }

  // ── Favourite helpers ──────────────────────────────────────────────────────

  void _openDetails(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    final product = _product;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        listing: product,
        price: _price,
        title: product.title,
        city: product.city ?? 'İstanbul',
        subCategory: product.subcategoryDisplay.isNotEmpty
            ? product.subcategoryDisplay
            : product.brand,
      ),
    );
  }

  Future<void> _toggleFavorite(
    FavoritesCubit favoriteStore,
    String listingId,
    bool enabled,
  ) async {
    final product = _product;
    try {
      await favoriteStore.toggle(
        listingId: listingId,
        enabled: enabled,
        item: EngagementItem(
          id: listingId,
          title: product.title,
          imageUrl: _imagePath,
          subtitle: _price,
          videoUrl: _videoUrl,
          categoryId: product.categoryId,
        ),
      );
      widget.onFavoriteToggle?.call();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.favoritesUpdateFailed),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final favoriteStore = context.watch<FavoritesCubit>();
    final product = _product;
    final listingId = product.id;
    final isFavorite = listingId.isEmpty
        ? _isFavorite
        : favoriteStore.isFavorite(listingId);
    final location = product.localizedLocation(context.l10n);
    final timeAgo = _localizedTimeAgo(product, context.l10n);

    return GestureDetector(
      onTap: () => _openDetails(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: ColoredBox(
          color: AppColor.bgSurfaceColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Media background ──
              VisibilityDetector(
                key: ObjectKey(this),
                onVisibilityChanged: _onVisibilityChanged,
                child: _buildVideoBackground(),
              ),

              // ── Top gradient ─────────────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.175],
                    ),
                  ),
                ),
              ),

              // ── Bottom gradient ──────────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.74, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Favourite button ─────────────────────────────────────────
              Positioned(
                right: 8.w,
                top: 12.h,
                child: InkWell(
                  onTap: () {
                    final nextValue = !isFavorite;
                    if (listingId.isEmpty) {
                      setState(() => _isFavorite = nextValue);
                      widget.onFavoriteToggle?.call();
                      return;
                    }
                    _toggleFavorite(favoriteStore, listingId, nextValue);
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: SvgPicture.asset(
                    'assets/icons/red_like_icon.dart.svg',
                    colorFilter: ColorFilter.mode(
                      isFavorite ? Colors.red : AppColor.secondaryTextColor,
                      BlendMode.srcIn,
                    ),
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),

              // ── Bottom details ───────────────────────────────────────────
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _price,
                          style: AppTextStyle.primaryText.copyWith(
                            color: AppColor.activeColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    2.height,
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.primaryText.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    2.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.primaryText.copyWith(
                              color: AppColor.secondaryTextColor,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: AppTextStyle.primaryText.copyWith(
                            color: AppColor.secondaryTextColor,
                            fontSize: 8.sp,
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
      ),
    );
  }

  // ── Media sub-builders ──────────────────────────────────────────────────────

  Widget _buildVideoBackground() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }
    if (controller != null && !_videoFailed) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildPoster(),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }
    if (_videoFailed) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildPoster(),
          Center(
            child: TextButton.icon(
              onPressed: _retryVideo,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ),
        ],
      );
    }
    return _buildPoster();
  }

  Widget _buildPoster() {
    const fallback = ColoredBox(color: Color(0xFF161A22));
    final path = _imagePath.trim();
    if (path.isEmpty) return fallback;
    final uri = Uri.tryParse(path);
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (uri?.scheme == 'file') {
      return Image.file(
        File.fromUri(uri!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    final networkUri = VideoUrlResolver.resolveNetworkUrl(path);
    if (networkUri != null) {
      return Image.network(
        networkUri.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }

  String _formattedPrice(Product product) =>
      CurrencyFormatter.formatPrice(product.price, product.currency);

  String _localizedTimeAgo(Product product, AppLocalizations l10n) {
    final updatedAt = product.updatedAt;
    final createdAt = product.createdAt;
    final date = updatedAt ?? createdAt;
    if (date == null) return '';

    final elapsed = DateTime.now().difference(date);
    if (elapsed.inDays > 0) return l10n.dayAgo(elapsed.inDays);
    if (elapsed.inHours > 0) return l10n.hoursAgo(elapsed.inHours);
    return '';
  }
}

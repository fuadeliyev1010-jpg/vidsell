import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vidsell/core/utils/video_url_resolver.dart';
import 'package:vidsell/models/video/feed_item.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class HomeFeedMedia extends StatefulWidget {
  const HomeFeedMedia({
    super.key,
    required this.listing,
    required this.playing,
    this.muted = false,
    this.playbackSession = 0,
    this.fit = BoxFit.cover,
  });

  final FeedItem listing;
  final bool playing;
  final bool muted;
  final int playbackSession;
  final BoxFit fit;

  @override
  State<HomeFeedMedia> createState() => _HomeFeedMediaState();
}

class _HomeFeedMediaState extends State<HomeFeedMedia> {
  VideoPlayerController? _controller;
  bool _videoFailed = false;
  int _playbackRequest = 0;

  @override
  void initState() {
    super.initState();
    if (widget.playing) _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant HomeFeedMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.videoUrl != widget.listing.videoUrl) {
      _disposeController();
      _videoFailed = false;
      if (widget.playing) _initializeVideo();
    } else if (oldWidget.playing != widget.playing ||
        oldWidget.playbackSession != widget.playbackSession) {
      if (widget.playing && _controller == null && !_videoFailed) {
        _initializeVideo();
      } else {
        _setPlaybackState(
          restart:
              widget.playing &&
              oldWidget.playbackSession != widget.playbackSession,
        );
      }
    }
    if (oldWidget.muted != widget.muted) {
      _setMuted();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _initializeVideo() {
    final videoUrl = widget.listing.videoUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    late final VideoPlayerController controller;
    if (videoUrl.startsWith('assets/')) {
      controller = VideoPlayerController.asset(videoUrl);
    } else if (videoUrl.startsWith('/')) {
      controller = VideoPlayerController.file(File(videoUrl));
    } else {
      final uri = Uri.tryParse(videoUrl);
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
      await controller.setVolume(widget.muted ? 0 : 1);
      await _setPlaybackState(restart: widget.playing);
      if (mounted) setState(() {});
    } catch (error) {
      _showVideoError(controller, error: error);
    }
  }

  void _showVideoError(VideoPlayerController controller, {Object? error}) {
    if (!mounted || controller != _controller || _videoFailed) return;
    if (kDebugMode) {
      debugPrint(
        'HomeListingMedia video error: '
        '${controller.value.errorDescription}; caught: $error',
      );
    }
    setState(() => _videoFailed = true);
  }

  Future<void> _setMuted() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setVolume(widget.muted ? 0 : 1);
    } catch (error) {
      _showVideoError(controller, error: error);
    }
  }

  Future<void> _setPlaybackState({bool restart = false}) async {
    final request = ++_playbackRequest;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      if (widget.playing) {
        if (restart) {
          await controller.seekTo(Duration.zero);
          if (!mounted ||
              controller != _controller ||
              request != _playbackRequest ||
              !widget.playing) {
            return;
          }
        }
        await controller.play();
      } else {
        await controller.pause();
      }
    } catch (error) {
      _showVideoError(controller, error: error);
    }
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

  ImageProvider? _posterProvider() {
    final path =
        (widget.listing.thumbnailUrl ??
                (widget.listing.product?.imageUrls.isNotEmpty == true
                    ? widget.listing.product!.imageUrls.first
                    : ''))
            .trim();
    if (path.isEmpty) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    if (path.startsWith('/')) return FileImage(File(path));
    final uri = Uri.tryParse(path);
    if (uri?.scheme == 'file') return FileImage(File.fromUri(uri!));
    final networkUri = VideoUrlResolver.resolveNetworkUrl(path);
    return networkUri == null ? null : NetworkImage(networkUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final poster = _posterProvider();
    final controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster != null)
          Image(
            image: poster,
            fit: widget.fit,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Color(0xFF161A22),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white38,
                ),
              ),
            ),
          )
        else
          const ColoredBox(color: Color(0xFF161A22)),
        if (controller != null && controller.value.isInitialized)
          ClipRect(
            child: FittedBox(
              fit: widget.fit,
              alignment: Alignment.center,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else if (controller != null && !_videoFailed)
          const Center(child: CircularProgressIndicator(color: Colors.white70)),
        if (_videoFailed)
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
}

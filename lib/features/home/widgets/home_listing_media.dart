import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vidsell/features/home/models/home_listing.dart';

class HomeListingMedia extends StatefulWidget {
  const HomeListingMedia({
    super.key,
    required this.listing,
    required this.playing,
    this.muted = false,
    this.playbackSession = 0,
    this.fit = BoxFit.cover,
  });

  final HomeListing listing;
  final bool playing;
  final bool muted;
  final int playbackSession;
  final BoxFit fit;

  @override
  State<HomeListingMedia> createState() => _HomeListingMediaState();
}

class _HomeListingMediaState extends State<HomeListingMedia> {
  VideoPlayerController? _controller;
  bool _videoFailed = false;
  int _playbackRequest = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant HomeListingMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.videoUrl != widget.listing.videoUrl) {
      _disposeController();
      _videoFailed = false;
      _initializeVideo();
    } else if (oldWidget.playing != widget.playing ||
        oldWidget.playbackSession != widget.playbackSession) {
      _setPlaybackState(
        restart:
            widget.playing &&
            oldWidget.playbackSession != widget.playbackSession,
      );
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
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) {
      _videoFailed = true;
      return;
    }

    late final VideoPlayerController controller;
    if (uri.hasScheme) {
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        controller = VideoPlayerController.networkUrl(uri);
      } else if (uri.scheme == 'file') {
        controller = VideoPlayerController.file(File.fromUri(uri));
      } else {
        _videoFailed = true;
        return;
      }
    } else {
      controller = videoUrl.startsWith('/')
          ? VideoPlayerController.file(File(videoUrl))
          : VideoPlayerController.asset(videoUrl);
    }

    _controller = controller;
    unawaited(_loadVideo(controller));
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
      if (!mounted || controller != _controller) return;
      if (kDebugMode) {
        debugPrint(
          'HomeListingMedia video error: '
          '${controller.value.errorDescription}; caught: $error',
        );
      }
      setState(() => _videoFailed = true);
    }
  }

  Future<void> _setMuted() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setVolume(widget.muted ? 0 : 1);
    } catch (error) {
      if (!mounted || controller != _controller) return;
      if (kDebugMode) {
        debugPrint(
          'HomeListingMedia video error: '
          '${controller.value.errorDescription}; caught: $error',
        );
      }
      setState(() => _videoFailed = true);
    }
  }

  Future<void> _setPlaybackState({bool restart = false}) async {
    final request = ++_playbackRequest;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
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
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
  }

  ImageProvider? _posterProvider() {
    final path = widget.listing.imagePath;
    if (path.isEmpty) return null;
    if (widget.listing.isNetworkMedia) return NetworkImage(path);
    if (path.startsWith('assets/')) return AssetImage(path);
    final file = File(path);
    return file.existsSync() ? FileImage(file) : AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    final poster = widget.listing.hasVideo ? null : _posterProvider();
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
          const Center(child: CircularProgressIndicator(color: Colors.white70))
        else if (_videoFailed)
          const Center(
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.white70,
              size: 30,
            ),
          ),
      ],
    );
  }
}

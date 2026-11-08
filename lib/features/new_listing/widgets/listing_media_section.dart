import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail_platform_interface.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/video_picker_bottom_sheet.dart';
import 'package:vidsell/features/new_listing/widgets/listing_form_components.dart';

import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ListingMediaSection extends StatelessWidget {
  const ListingMediaSection({
    super.key,
    required this.imagePaths,
    required this.videoPaths,
    required this.videoDurations,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.onVideoAdded,
    required this.onVideoRemoved,
    required this.onVideoCoverChanged,
  });

  final List<String> imagePaths;
  final List<String> videoPaths;
  final List<Duration> videoDurations;
  final ValueChanged<String> onImageAdded;
  final ValueChanged<int> onImageRemoved;
  final void Function(String path, Duration duration) onVideoAdded;
  final ValueChanged<int> onVideoRemoved;
  final void Function(int index, String path) onVideoCoverChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListingSectionHeader(context.l10n.listingVideoSection),
        8.height,
        if (videoPaths.isEmpty)
          InkWell(
            onTap: () => showVideoPickerBottomSheet(
              context: context,
              title: context.l10n.newListingVideoTitle,
              onVideoSelected: (file, duration) =>
                  onVideoAdded(file.path, duration),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.activeColor, width: 1.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.videocam,
                    color: AppColor.activeColor,
                    size: 24.sp,
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.videoAdd,
                          style: AppTextStyle.primaryText.copyWith(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        2.height,
                        Text(
                          context.l10n.videoAddHint,
                          style: AppTextStyle.mutedText.copyWith(
                            fontSize: 10.sp,
                            color: AppColor.tertiaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _VideoMediaList(
            paths: videoPaths,
            durations: videoDurations,
            onRemoved: onVideoRemoved,
            onCoverChanged: onVideoCoverChanged,
          ),
      ],
    );
  }
}

class _VideoMediaList extends StatelessWidget {
  const _VideoMediaList({
    required this.paths,
    required this.durations,
    required this.onRemoved,
    required this.onCoverChanged,
  });

  final List<String> paths;
  final List<Duration> durations;
  final ValueChanged<int> onRemoved;
  final void Function(int index, String path) onCoverChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          paths.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _VideoMediaCard(
              path: paths[index],
              duration: index < durations.length
                  ? durations[index]
                  : Duration.zero,
              onRemoved: () => onRemoved(index),
              onCoverChanged: (coverPath) => onCoverChanged(index, coverPath),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoMediaCard extends StatefulWidget {
  const _VideoMediaCard({
    required this.path,
    required this.duration,
    required this.onRemoved,
    required this.onCoverChanged,
  });

  final String path;
  final Duration duration;
  final VoidCallback onRemoved;
  final ValueChanged<String> onCoverChanged;

  @override
  State<_VideoMediaCard> createState() => _VideoMediaCardState();
}

class _VideoMediaCardState extends State<_VideoMediaCard> {
  Uint8List? _thumbnail;
  Timer? _thumbnailTimer;
  int _positionMs = 0;
  int _thumbnailRequest = 0;
  bool _isLoadingThumbnail = true;

  int get _durationMs => widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _generateThumbnail(0);
  }

  @override
  void dispose() {
    _thumbnailTimer?.cancel();
    super.dispose();
  }

  void _onPositionChanged(double value) {
    final position = value.round();
    setState(() => _positionMs = position);
    _thumbnailTimer?.cancel();
    _thumbnailTimer = Timer(
      const Duration(milliseconds: 250),
      () => _generateThumbnail(position),
    );
  }

  Future<void> _generateThumbnail(int timeMs) async {
    final request = ++_thumbnailRequest;
    if (mounted) setState(() => _isLoadingThumbnail = true);

    try {
      final frameTimeMs = _durationMs > 0
          ? timeMs.clamp(0, _durationMs - 1)
          : 0;
      final bytes = await FcNativeVideoThumbnail().saveThumbnailToBytes(
        srcFile: widget.path,
        width: 300,
        height: 300,
        at: FcVideoThumbnailTime(
          frameTimeMs,
          FcVideoThumbnailTimeUnit.milliseconds,
        ),
        quality: 85,
      );
      if (bytes == null) {
        throw StateError('Video frame could not be generated.');
      }
      if (!mounted || request != _thumbnailRequest) return;

      final temporaryDirectory = await getTemporaryDirectory();
      final coverFile = File(
        path.join(
          temporaryDirectory.path,
          'vidsell-video-cover-${widget.path.hashCode}-$frameTimeMs.jpg',
        ),
      );
      await coverFile.writeAsBytes(bytes, flush: true);

      if (!mounted || request != _thumbnailRequest) return;
      setState(() {
        _thumbnail = bytes;
        _isLoadingThumbnail = false;
      });
      widget.onCoverChanged(coverFile.path);
    } catch (error) {
      if (!mounted || request != _thumbnailRequest) return;
      setState(() => _isLoadingThumbnail = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.videoFrameCreationFailed,
            ),
          ),
        );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final maxPosition = _durationMs > 0 ? _durationMs.toDouble() : 1.0;
    final position = _positionMs.clamp(0, maxPosition.toInt()).toDouble();

    return SizedBox(
      width: 126.w,
      height: 156.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: AppColor.bgSecondary,
              child: _thumbnail == null
                  ? const Icon(
                      Icons.videocam,
                      color: AppColor.tertiaryTextColor,
                    )
                  : Image.memory(_thumbnail!, fit: BoxFit.cover),
            ),
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 3.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(175),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 5.r,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 9.r,
                        ),
                      ),
                      child: Slider(
                        min: 0,
                        max: maxPosition,
                        value: position,
                        activeColor: AppColor.activeColor,
                        inactiveColor: Colors.white54,
                        onChanged: _onPositionChanged,
                        onChangeEnd: (value) {
                          _thumbnailTimer?.cancel();
                          _generateThumbnail(value.round());
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(Duration(milliseconds: _positionMs)),
                          style: AppTextStyle.mutedText.copyWith(
                            fontSize: 9.sp,
                            color: Colors.white,
                          ),
                        ),
                        if (_isLoadingThumbnail)
                          SizedBox(
                            width: 9.w,
                            height: 9.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColor.activeColor,
                            ),
                          ),
                        Text(
                          _formatDuration(widget.duration),
                          style: AppTextStyle.mutedText.copyWith(
                            fontSize: 9.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4.w,
              right: 4.w,
              child: InkWell(
                onTap: widget.onRemoved,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

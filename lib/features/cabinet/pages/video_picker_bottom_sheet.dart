import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

void showVideoPickerBottomSheet({
  required BuildContext context,
  required Function(File videoFile, Duration duration) onVideoSelected,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(120),
    builder: (context) =>
        VideoPickerBottomSheet(onVideoSelected: onVideoSelected, title: title),
  );
}

class VideoPickerBottomSheet extends StatefulWidget {
  final Function(File videoFile, Duration duration) onVideoSelected;
  final String? title;

  const VideoPickerBottomSheet({
    super.key,
    required this.onVideoSelected,
    this.title,
  });

  @override
  State<VideoPickerBottomSheet> createState() => _VideoPickerBottomSheetState();
}

class _VideoPickerBottomSheetState extends State<VideoPickerBottomSheet> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  final List<AssetEntity> _videoList = [];
  String? _selectedVideoId;

  bool _isLoading = true;
  bool _showAlbumDropdown = false;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _showErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isNotEmpty) {
      _albums = albums;
      _selectedAlbum = albums.first;
      await _loadMediaForAlbum(_selectedAlbum!, isRefresh: true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMediaForAlbum(
    AssetPathEntity album, {
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPage = 0;
      _videoList.clear();
      _hasMore = true;
    }

    final media = await album.getAssetListPaged(page: _currentPage, size: 40);

    if (mounted) {
      setState(() {
        _selectedAlbum = album;
        _videoList.addAll(media);
        _hasMore = media.length == 40;
        _showAlbumDropdown = false;
      });
    }
  }

  Future<String> _getVideoDuration(AssetEntity asset) async {
    final duration = asset.videoDuration;

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmSelectedVideo() async {
    final selectedId = _selectedVideoId;
    if (selectedId == null) return;

    final selectedAsset = _videoList.firstWhere(
      (asset) => asset.id == selectedId,
      orElse: () => _videoList.first,
    );

    final file = await selectedAsset.file;
    if (file != null && mounted) {
      Navigator.pop(context);
      widget.onVideoSelected(file, selectedAsset.videoDuration);
    }
  }

  void _toggleVideoSelection(String videoId) {
    setState(() {
      if (_selectedVideoId == videoId) {
        _selectedVideoId = null;
        _showErrorMessage = false;
        return;
      }

      if (_selectedVideoId != null) {
        _showErrorMessage = true;
        return;
      }

      _selectedVideoId = videoId;
      _showErrorMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.78,
      decoration: BoxDecoration(
        color: const Color(0xFF101A24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              8.height,
              Container(
                width: 36.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              10.height,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white70),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAlbumDropdown = !_showAlbumDropdown;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedAlbum?.name ?? 'All Videos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            4.width,
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _confirmSelectedVideo,
                      child: Text(
                        context.l10n.imageAdd,
                        style: TextStyle(
                          color: AppColor.activeColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              12.height,
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.activeColor,
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (!_isLoading &&
                              _hasMore &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            _currentPage++;
                            _loadMediaForAlbum(_selectedAlbum!);
                          }
                          return false;
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.w,
                              ),
                          itemCount: _videoList.length,
                          itemBuilder: (context, index) {
                            final asset = _videoList[index];
                            final isSelected = _selectedVideoId == asset.id;
                            return GestureDetector(
                              onTap: () => _toggleVideoSelection(asset.id),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: AssetEntityImage(
                                      asset,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize.square(
                                        300,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8.h,
                                    left: 8.w,
                                    child: FutureBuilder<String>(
                                      future: _getVideoDuration(asset),
                                      builder: (context, snapshot) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                          child: Text(
                                            snapshot.data ?? '0:00',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '1',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white60,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              if (_showErrorMessage)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 10.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3440),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4B942),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 12.sp,
                            color: Colors.black,
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.videoAddFailure,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              2.height,
                              Text(
                                context.l10n.videoLimit,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _showErrorMessage = false);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_showAlbumDropdown)
            Positioned(
              top: 56.h,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.25,
                    minWidth: 160.w,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF232D38),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        itemCount: _albums.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (context, index) {
                          final album = _albums[index];
                          return _buildAlbumTile(album);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumTile(AssetPathEntity album) {
    final isSelected = _selectedAlbum?.id == album.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _loadMediaForAlbum(album, isRefresh: true),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          color: isSelected ? Colors.white.withAlpha(15) : Colors.transparent,
          child: Text(
            album.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/features/cabinet/pages/image_cropper_page.dart';
import 'package:vidsell/features/cabinet/widgets/circle_crop_overlay_painter.dart';

void showMediaPickerBottomSheet({
  required BuildContext context,
  required Function(File croppedFile) onImageSelected,
  ImageCropShape cropShape = ImageCropShape.circle,
  double aspectRatio = 1,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MediaPickerBottomSheet(
      onImageSelected: onImageSelected,
      cropShape: cropShape,
      aspectRatio: aspectRatio,
    ),
  );
}

class MediaPickerBottomSheet extends StatefulWidget {
  final Function(File croppedFile) onImageSelected;
  final ImageCropShape cropShape;
  final double aspectRatio;

  const MediaPickerBottomSheet({
    super.key,
    required this.onImageSelected,
    this.cropShape = ImageCropShape.circle,
    this.aspectRatio = 1,
  });

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  final List<AssetEntity> _mediaList = [];

  bool _isLoading = true;
  bool _showAlbumDropdown = false;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingPage = false;
  int _loadRequestGeneration = 0;

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
      type: RequestType.image,
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
    if (!isRefresh && (_isLoadingPage || !_hasMore)) return;

    final requestGeneration = ++_loadRequestGeneration;
    final page = isRefresh ? 0 : _currentPage + 1;
    _isLoadingPage = true;

    if (isRefresh) {
      setState(() {
        _selectedAlbum = album;
        _currentPage = -1;
        _mediaList.clear();
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final media = await album.getAssetListPaged(page: page, size: 40);
      if (!mounted || requestGeneration != _loadRequestGeneration) return;

      setState(() {
        _selectedAlbum = album;
        _currentPage = page;
        _mediaList.addAll(media);
        _hasMore = media.length == 40;
        _showAlbumDropdown = false;
        _isLoading = false;
      });
    } finally {
      if (mounted && requestGeneration == _loadRequestGeneration) {
        setState(() {
          _isLoadingPage = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleMediaTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null && mounted) {
      final croppedFile = await context.goTo<File>(
        ImageCropperPage(
          imageFile: file,
          cropShape: widget.cropShape,
          aspectRatio: widget.aspectRatio,
        ),
      );

      if (croppedFile != null && mounted) {
        Navigator.pop(context);
        widget.onImageSelected(croppedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFF111418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              10.height,
              // Drag Indicator
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Album Dropdown Toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAlbumDropdown = !_showAlbumDropdown;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedAlbum?.name ?? 'All Photos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          6.width,
                          Icon(
                            _showAlbumDropdown
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Image Grid
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
                              !_isLoadingPage &&
                              _hasMore &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            _loadMediaForAlbum(_selectedAlbum!);
                          }
                          return false;
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.all(2.r),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2.r,
                                mainAxisSpacing: 2.r,
                              ),
                          itemCount: _mediaList.length,
                          itemBuilder: (context, index) {
                            final asset = _mediaList[index];
                            return GestureDetector(
                              onTap: () => _handleMediaTap(asset),
                              child: AssetEntityImage(
                                asset,
                                isOriginal: false,
                                thumbnailSize: const ThumbnailSize.square(250),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),

          // Dynamic Album Selection Dropdown
          if (_showAlbumDropdown)
            Positioned(
              top: 48.h,
              left: 20.w,
              right: 20.w,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.45),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C232D),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 8.w,
                      ),
                      itemCount: _albums.length,
                      separatorBuilder: (context, index) => 4.height,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        return _buildAlbumTile(album);
                      },
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
        borderRadius: BorderRadius.circular(10.r),
        onTap: () => _loadMediaForAlbum(album, isRefresh: true),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              // Folder First Image Thumbnail
              FutureBuilder<List<AssetEntity>>(
                future: album.getAssetListPaged(page: 0, size: 1),
                builder: (context, snapshot) {
                  final hasAsset =
                      snapshot.hasData && snapshot.data!.isNotEmpty;
                  if (!hasAsset) {
                    return Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3542),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SizedBox(
                      width: 44.r,
                      height: 44.r,
                      child: AssetEntityImage(
                        snapshot.data!.first,
                        isOriginal: false,
                        thumbnailSize: const ThumbnailSize.square(150),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              12.width,
              // Folder Title
              Expanded(
                child: Text(
                  album.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              8.width,
              // Asset Count
              FutureBuilder<int>(
                future: album.assetCountAsync,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
              4.width,
            ],
          ),
        ),
      ),
    );
  }
}

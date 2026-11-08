import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/cabinet/widgets/circle_crop_overlay_painter.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class ImageCropperPage extends StatefulWidget {
  final File imageFile;
  final ImageCropShape cropShape;
  final double aspectRatio;

  const ImageCropperPage({
    super.key,
    required this.imageFile,
    this.cropShape = ImageCropShape.circle,
    this.aspectRatio = 1,
  }) : assert(aspectRatio > 0);

  @override
  State<ImageCropperPage> createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
  final TransformationController _transformationController =
      TransformationController();

  int _quarterTurns = 0;
  bool _isFlippedHorizontally = false;
  ui.Image? _decodedImage;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
      });
    }
  }

  void _rotateImage() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _flipImage() {
    setState(() {
      _isFlippedHorizontally = !_isFlippedHorizontally;
    });
  }

  Future<void> _cropAndSave() async {
    if (_decodedImage == null || _isCropping) return;

    setState(() => _isCropping = true);

    try {
      final cropWidth = MediaQuery.sizeOf(context).width * 0.85;
      final cropHeight = cropWidth / widget.aspectRatio;
      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final rect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
      canvas.scale(pixelRatio);

      if (widget.cropShape == ImageCropShape.circle) {
        canvas.clipPath(Path()..addOval(rect));
      } else {
        canvas.clipRect(rect);
      }

      final Matrix4 matrix = _transformationController.value.clone();

      canvas.transform(matrix.storage);

      canvas.translate(cropWidth / 2, cropHeight / 2);
      if (_isFlippedHorizontally) canvas.scale(-1.0, 1.0);
      canvas.rotate(_quarterTurns * (3.141592653589793 / 2));
      canvas.translate(-cropWidth / 2, -cropHeight / 2);

      final imageRect = _quarterTurns.isEven
          ? rect
          : Rect.fromCenter(
              center: rect.center,
              width: cropHeight,
              height: cropWidth,
            );
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: _decodedImage!,
        fit: BoxFit.cover,
      );

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(
        (cropWidth * pixelRatio).toInt(),
        (cropHeight * pixelRatio).toInt(),
      );
      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(byteData.buffer.asUint8List());

        if (mounted) {
          context.goBack(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.imageCropError)));
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropWidth = MediaQuery.sizeOf(context).width * 0.85;
    final cropHeight = cropWidth / widget.aspectRatio;
    final cropRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);

    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18.sp,
          ),
          onPressed: context.goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: SizedBox(
                width: cropWidth,
                height: cropHeight,
                child: Stack(
                  children: [
                    // Interactive Zoom / Pan Layer
                    Positioned.fill(
                      child: ClipRRect(
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 4.5,
                          boundaryMargin: EdgeInsets.all(cropWidth),
                          child: RotatedBox(
                            quarterTurns: _quarterTurns,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scaleByDouble(
                                  _isFlippedHorizontally ? -1.0 : 1.0,
                                  1.0,
                                  1.0,
                                  1.0,
                                ),
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.cover,
                                width: _quarterTurns.isEven
                                    ? cropWidth
                                    : cropHeight,
                                height: _quarterTurns.isEven
                                    ? cropHeight
                                    : cropWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Dark Overlay with Circular Cutout
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: CircleCropOverlayPainter(
                            cropRect: cropRect,
                            shape: widget.cropShape,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Action Control Bar matching design
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rotate Button
                  IconButton(
                    icon: Icon(
                      Icons.rotate_right_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                    onPressed: _rotateImage,
                  ),
                  // Flip Horizontal Button
                  IconButton(
                    icon: Icon(
                      Icons.flip_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                    onPressed: _flipImage,
                  ),
                  // Confirm Crop Checkmark Button
                  GestureDetector(
                    onTap: _isCropping ? null : _cropAndSave,
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: const BoxDecoration(
                        color: AppColor.activeColor,
                        shape: BoxShape.circle,
                      ),
                      child: _isCropping
                          ? Padding(
                              padding: EdgeInsets.all(12.r),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.check, color: Colors.white, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

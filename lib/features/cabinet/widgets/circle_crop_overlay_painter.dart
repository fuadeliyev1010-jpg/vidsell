import 'package:flutter/material.dart';

enum ImageCropShape { circle, square, rectangle }

class CircleCropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final ImageCropShape shape;

  const CircleCropOverlayPainter({required this.cropRect, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cropPath = Path();
    switch (shape) {
      case ImageCropShape.circle:
        cropPath.addOval(cropRect);
        break;
      case ImageCropShape.square:
      case ImageCropShape.rectangle:
        cropPath.addRect(cropRect);
        break;
    }

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cropPath,
    );

    canvas.drawPath(overlayPath, paint);

    final borderPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (shape == ImageCropShape.circle) {
      canvas.drawOval(cropRect, borderPaint);
    } else {
      canvas.drawRect(cropRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleCropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect || oldDelegate.shape != shape;
}

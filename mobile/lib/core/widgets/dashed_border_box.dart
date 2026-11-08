import 'package:flutter/material.dart';

class DashedBorderBox extends StatelessWidget {
  final Widget? child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const DashedBorderBox({
    super.key,
    this.child,
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 4.0,
    this.dashGap = 4.0,
    this.borderRadius = 0.0,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;
  final Color? backgroundColor;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.borderRadius,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (backgroundColor != null) {
      final bgPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      if (borderRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
          bgPaint,
        );
      } else {
        canvas.drawRect(rect, bgPaint);
      }
    }

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final halfStroke = strokeWidth / 2;
    final adjustedRect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final path = Path();
    if (borderRadius > 0) {
      path.addRRect(
        RRect.fromRectAndRadius(adjustedRect, Radius.circular(borderRadius)),
      );
    } else {
      path.addRect(adjustedRect);
    }

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final currentLength = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + currentLength),
          Offset.zero,
        );
        distance += dashLength + dashGap;
      }
    }

    canvas.drawPath(dashedPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

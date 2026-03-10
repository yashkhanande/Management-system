import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:managementt/model/dashboard_models.dart';

class DonutChartPainter extends CustomPainter {
  final List<StatusData> segments;

  DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) return;

    final strokeWidth = size.width * 0.20;
    final radius = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.count / total) * (2 * math.pi);
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

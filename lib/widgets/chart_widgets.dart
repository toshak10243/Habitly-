import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive & Custom-Painted Bar Chart for Weekly Completion
class WeeklyBarChartWidget extends StatelessWidget {
  final List<String> dayLabels;
  final List<double> completionRates; // 0.0 to 1.0
  final List<int> completedCounts;
  final List<int> totalCounts;

  const WeeklyBarChartWidget({
    super.key,
    required this.dayLabels,
    required this.completionRates,
    required this.completedCounts,
    required this.totalCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Completion Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Past 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Daily habit execution percentage across the current week',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _BarChartPainter(
                dayLabels: dayLabels,
                rates: completionRates,
                primaryColor: const Color(0xFF4F46E5),
                bgTrackColor: const Color(0xFFF1F5F9),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend / Detail Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(dayLabels.length, (index) {
              final pct = (completionRates[index] * 100).round();
              return Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> dayLabels;
  final List<double> rates;
  final Color primaryColor;
  final Color bgTrackColor;

  _BarChartPainter({
    required this.dayLabels,
    required this.rates,
    required this.primaryColor,
    required this.bgTrackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = dayLabels.length;
    if (count == 0) return;

    final bottomPadding = 26.0;
    final chartHeight = size.height - bottomPadding;
    final barWidth = (size.width / count) * 0.45;
    final spacing = size.width / count;

    final trackPaint = Paint()
      ..color = bgTrackColor
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < count; i++) {
      final centerX = (i * spacing) + (spacing / 2);
      final left = centerX - (barWidth / 2);
      final right = centerX + (barWidth / 2);

      // Background rounded pill track
      final trackRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, 0, right, chartHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(trackRRect, trackPaint);

      // Foreground bar
      final rate = rates[i].clamp(0.0, 1.0);
      if (rate > 0) {
        final barTop = chartHeight * (1.0 - rate);
        final barRRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(left, barTop, right, chartHeight),
          const Radius.circular(8),
        );
        canvas.drawRRect(barRRect, barPaint);
      }

      // Day Label below
      final textPainter = TextPainter(
        text: TextSpan(
          text: dayLabels[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.rates != rates;
  }
}

/// Custom-Painted Donut Chart for Category-wise Distribution
class CategoryDonutChartWidget extends StatelessWidget {
  final Map<String, int> categoryCounts;

  const CategoryDonutChartWidget({
    super.key,
    required this.categoryCounts,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryCounts.values.fold<int>(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF10B981), // Mint
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
    ];

    final entries = categoryCounts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Proportion of active habits by focus area',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('No habit categories yet.',
                    style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            )
          else ...[
            Row(
              children: [
                // Donut chart
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutChartPainter(
                      entries: entries,
                      colors: colors,
                      total: total,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Text(
                            'Habits',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(entries.length, (idx) {
                      final item = entries[idx];
                      final color = colors[idx % colors.length];
                      final pct = total > 0 ? (item.value / total * 100).round() : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF334155),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final List<Color> colors;
  final int total;

  _DonutChartPainter({
    required this.entries,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 24.0;
    final arcRadius = radius - strokeWidth / 2;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Custom-Painted Monthly Trend Smooth Line Chart
class MonthlyTrendLineChartWidget extends StatelessWidget {
  final List<double> dailyRates; // 30 days of data

  const MonthlyTrendLineChartWidget({
    super.key,
    required this.dailyRates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '30-Day Completion Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consistency curve and momentum over the past month',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _LineTrendPainter(
                rates: dailyRates,
                lineColor: const Color(0xFF10B981),
                fillColor: const Color(0xFF10B981).withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30 days ago', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('15 days ago', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('Today', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineTrendPainter extends CustomPainter {
  final List<double> rates;
  final Color lineColor;
  final Color fillColor;

  _LineTrendPainter({
    required this.rates,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rates.isEmpty) return;

    final stepX = size.width / (rates.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < rates.length; i++) {
      final x = i * stepX;
      final y = size.height - (rates[i].clamp(0.0, 1.0) * (size.height - 10)) - 5;
      points.add(Offset(x, y));
    }

    // Draw smooth line & fill path
    final path = Path();
    final fillPath = Path();

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Fill area
    final areaPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, areaPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // End point highlight
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(points.last, 5, dotPaint);
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(points.last, 5, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _LineTrendPainter oldDelegate) => true;
}


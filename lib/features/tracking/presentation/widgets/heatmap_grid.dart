import 'package:material_ui/material_ui.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';

/// High-performance GitHub-style 7-row contribution heatmap grid rendered via
/// [CustomPainter], supporting 16-week and 52-week scrollable views and tap
/// hit-testing per cell.
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.cells,
    required this.weeks,
    this.accentColor,
    this.cellSize = 16,
    this.cellGap = 4,
    this.onCellTap,
  });

  final List<HeatmapCell> cells;
  final int weeks;
  final Color? accentColor;
  final double cellSize;
  final double cellGap;
  final ValueChanged<HeatmapCell>? onCellTap;

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    final ramp = accentColor != null
        ? colors.rampForAccent(accentColor!)
        : colors.heatmapLevels;

    final gridWidth = weeks * (cellSize + cellGap) - cellGap;
    final gridHeight = 7 * (cellSize + cellGap) - cellGap;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: List.generate(7, (row) {
              return SizedBox(
                height: cellSize + (row < 6 ? cellGap : 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _weekdayLabels[row],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: GestureDetector(
              onTapUp: onCellTap == null
                  ? null
                  : (details) {
                      final col =
                          (details.localPosition.dx / (cellSize + cellGap))
                              .floor();
                      final row =
                          (details.localPosition.dy / (cellSize + cellGap))
                              .floor();
                      if (col >= 0 && col < weeks && row >= 0 && row < 7) {
                        final index = col * 7 + row;
                        if (index >= 0 && index < cells.length) {
                          final cell = cells[index];
                          if (!cell.isFuture) {
                            onCellTap!(cell);
                          }
                        }
                      }
                    },
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(gridWidth, gridHeight),
                  painter: _HeatmapPainter(
                    cells: cells,
                    weeks: weeks,
                    cellSize: cellSize,
                    cellGap: cellGap,
                    ramp: ramp,
                    shieldColor: colors.shield,
                    restBorderColor: colors.textSecondary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.cells,
    required this.weeks,
    required this.cellSize,
    required this.cellGap,
    required this.ramp,
    required this.shieldColor,
    required this.restBorderColor,
  });

  final List<HeatmapCell> cells;
  final int weeks;
  final double cellSize;
  final double cellGap;
  final List<Color> ramp;
  final Color shieldColor;
  final Color restBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(cellSize * 0.26);
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final shieldPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = shieldColor;
    final restStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = restBorderColor;

    for (var col = 0; col < weeks; col++) {
      for (var row = 0; row < 7; row++) {
        final idx = col * 7 + row;
        if (idx >= cells.length) continue;
        final cell = cells[idx];

        final left = col * (cellSize + cellGap);
        final top = row * (cellSize + cellGap);
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellSize, cellSize),
          radius,
        );

        if (cell.isFuture) {
          fillPaint.color = ramp[0].withValues(alpha: 0.35);
          canvas.drawRRect(rrect, fillPaint);
          continue;
        }

        fillPaint.color = ramp[cell.level.clamp(0, 4)];
        canvas.drawRRect(rrect, fillPaint);

        if (cell.hasRestDay) {
          canvas.drawRRect(rrect.deflate(0.6), restStroke);
        }

        if (cell.hasShield) {
          final center = Offset(left + cellSize / 2, top + cellSize / 2);
          canvas.drawCircle(center, cellSize * 0.19, shieldPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.cells != cells ||
        oldDelegate.ramp != ramp ||
        oldDelegate.weeks != weeks;
  }
}

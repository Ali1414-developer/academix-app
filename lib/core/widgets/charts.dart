import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ScoreRingChart extends StatelessWidget {
  final double value; // 0 to 100
  final String centerLabel;
  final String caption;
  final Color color;
  final double size;

  const ScoreRingChart({
    super.key,
    required this.value,
    required this.centerLabel,
    required this.caption,
    required this.color,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 100.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: size * 0.34,
                  sections: [
                    PieChartSectionData(
                      value: clamped,
                      color: color,
                      radius: size * 0.14,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (100 - clamped).clamp(0.0, 100.0),
                      color: AppColors.border,
                      radius: size * 0.14,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Text(
                centerLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class MetricBarRow extends StatelessWidget {
  final String label;
  final double value; // 0 to 100
  final String displayValue;
  final Color color;

  const MetricBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.displayValue,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.border.withValues(alpha: 0.65),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class SimpleBarSeriesItem {
  final String label;
  final double value;
  final Color color;

  const SimpleBarSeriesItem({
    required this.label,
    required this.value,
    this.color = AppColors.primaryBlue,
  });
}

class AcademiXBarChart extends StatelessWidget {
  final List<SimpleBarSeriesItem> items;
  final double maxY;
  final String unitSuffix;

  const AcademiXBarChart({
    super.key,
    required this.items,
    this.maxY = 100,
    this.unitSuffix = '%',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No chart data available yet',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primaryText,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${items[group.x].label}\n${rod.toY.toStringAsFixed(0)}$unitSuffix',
                  const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: maxY / 4,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i < 0 || i >= items.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      items[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(items.length, (index) {
            final item = items[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.value.clamp(0.0, maxY),
                  color: item.color,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

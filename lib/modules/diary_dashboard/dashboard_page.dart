import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../colors.dart';
import 'dashboard_controller.dart';
import 'dashboard_stats_model.dart';

class DiaryDashboardPage extends StatelessWidget {
  const DiaryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiaryDashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calorie Diary Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      backgroundColor: TColors.background,
      body: Obx(() {
        if (controller.isLoading) {
          return _buildLoadingState();
        }
        if (controller.hasError) {
          return _buildErrorState(controller);
        }
        if (!controller.hasData) {
          return _buildEmptyState(controller);
        }
        return _buildContent(controller);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: TColors.background3,
              highlightColor: TColors.background,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: TColors.background3,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(DiaryDashboardController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: TColors.error),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again later.',
            style: TextStyle(color: TColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.loadDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DiaryDashboardController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights_outlined, size: 72, color: TColors.accent),
          const SizedBox(height: 16),
          const Text(
            'No diary data yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add meals to your diary to see insights.',
            style: TextStyle(color: TColors.textSecondary),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: controller.loadDashboard,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: TColors.primary),
              foregroundColor: TColors.primary,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DiaryDashboardController controller) {
    final stats = controller.stats;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAnimatedCard(child: _buildBarChart(controller)),
          const SizedBox(height: 16),
          _buildAnimatedCard(child: _buildLineChart(controller)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedCard(child: _buildPieChart(controller)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnimatedCard(
                  child: _buildWeeklyAverageChart(controller),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats != null) _buildStatsSection(stats),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TColors.greyLight.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(DiaryDashboardController controller) {
    final days = controller.lastSevenDays;
    if (days.isEmpty) {
      return const Text(
        'Not enough data for bar chart',
        style: TextStyle(color: TColors.textSecondary),
      );
    }

    final groups = days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return BarChartGroupData(
        x: index,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: day.calories,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            color: TColors.primary,
          ),
          BarChartRodData(
            toY: day.target,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            color: TColors.accent,
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Intake vs Target (Last 7 Days)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: groups,
              gridData: FlGridData(show: true, horizontalInterval: 200),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final label =
                          DateFormat('EEE').format(days[index].date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 200,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            _Legend(color: TColors.primary, label: 'Consumed'),
            SizedBox(width: 16),
            _Legend(color: TColors.accent, label: 'Target'),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart(DiaryDashboardController controller) {
    final days = controller.daysData;
    final spots = days.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.calories);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '30-Day Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, horizontalInterval: 200),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 ||
                          index >= days.length ||
                          index % 5 != 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        DateFormat('dd').format(days[index].date),
                        style: const TextStyle(
                          fontSize: 10,
                          color: TColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 200,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minX: 0,
              maxX: (days.length - 1).toDouble(),
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: TColors.primary,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  spots: spots,
                ),
              ],
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: controller.targetCalories,
                  color: TColors.accent,
                  strokeWidth: 2,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    labelResolver: (_) => 'Target',
                    style: const TextStyle(
                      color: TColors.accent,
                      fontSize: 10,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(DiaryDashboardController controller) {
    final stats = controller.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final sections = [
      PieChartSectionData(
        color: TColors.success,
        value: stats.underPercentage,
        title: '${stats.underPercentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          color: TColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: TColors.error,
        value: stats.overPercentage,
        title: '${stats.overPercentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          color: TColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Under vs Over Calories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 32,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: const [
            _Legend(color: TColors.success, label: 'Under target'),
            SizedBox(width: 12),
            _Legend(color: TColors.error, label: 'Over target'),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyAverageChart(DiaryDashboardController controller) {
    final stats = controller.stats;
    if (stats == null || stats.weeklyAverages.isEmpty) {
      return const Text(
        'Weekly data not available',
        style: TextStyle(color: TColors.textSecondary),
      );
    }

    final spots = stats.weeklyAverages.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Averages',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      'W${value.toInt() + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 200,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: TColors.accent,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
              gridData: FlGridData(show: true, horizontalInterval: 200),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(DashboardStatsModel stats) {
    final cards = [
      _StatCardData(
        title: 'This Week',
        value: '${stats.thisWeekCalories.toStringAsFixed(0)} kcal',
        subtitle:
            '${stats.thisWeekDifference >= 0 ? '+' : ''}${stats.thisWeekDifference.toStringAsFixed(0)} kcal difference',
        icon: MdiIcons.calendarWeekOutline,
      ),
      _StatCardData(
        title: 'Best Streak',
        value: '${stats.bestStreak} days',
        subtitle: 'Under target streak',
        icon: MdiIcons.weatherSunny,
      ),
      _StatCardData(
        title: 'Avg Deviation',
        value: '${stats.averageDeviation.toStringAsFixed(0)} kcal',
        subtitle: 'From daily target',
        icon: MdiIcons.trendingUp,
      ),
      _StatCardData(
        title: 'Highest Day',
        value:
            '${stats.highestDay?.calories.toStringAsFixed(0) ?? 0} kcal',
        subtitle: stats.highestDay?.label ?? '--',
        icon: MdiIcons.fire,
      ),
      _StatCardData(
        title: 'Lowest Day',
        value: '${stats.lowestDay?.calories.toStringAsFixed(0) ?? 0} kcal',
        subtitle: stats.lowestDay?.label ?? '--',
        icon: MdiIcons.waterOutline,
      ),
      _StatCardData(
        title: 'Under Target',
        value: '${stats.underPercentage.toStringAsFixed(0)}%',
        subtitle: 'Days within goals',
        icon: MdiIcons.checkboxMarkedCircleOutline,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) {
        final data = cards[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.background3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: TColors.primary.withOpacity(0.15),
                child: Icon(data.icon, color: TColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.subtitle,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}


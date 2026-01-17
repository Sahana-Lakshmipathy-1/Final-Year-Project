import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lumora/theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Insights", style: AppTheme.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ------------------------------------------------------------
            /// TOP SUMMARY
            /// ------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.elevatedCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Great consistency this week 🔥", style: AppTheme.h3),
                  const SizedBox(height: 8),
                  Text(
                    "You walked more, slept better, and stayed balanced.",
                    style: AppTheme.bodyMuted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ------------------------------------------------------------
            /// STEPS
            /// ------------------------------------------------------------
            _InsightBlock(
              title: "Daily Steps",
              subtitle: "Your activity trend over the last 7 days",
              highlight: "Peak day: Saturday 🚀",
              chart: _stepsChart(),
            ),

            /// ------------------------------------------------------------
            /// SLEEP vs MOOD
            /// ------------------------------------------------------------
            _InsightBlock(
              title: "Sleep & Mood",
              subtitle: "Better sleep = better mood",
              highlight: "Mood improves after 7h sleep 😌",
              chart: _sleepMoodChart(),
            ),

            /// ------------------------------------------------------------
            /// CALORIES
            /// ------------------------------------------------------------
            _InsightBlock(
              title: "Calories Balance",
              subtitle: "Intake vs Burn",
              highlight: "Balanced most days ⚖️",
              chart: _caloriesChart(),
            ),

            const SizedBox(height: 32),

            /// ------------------------------------------------------------
            /// CTA
            /// ------------------------------------------------------------
            Center(
              child: ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () {},
                child: const Text("View detailed insights"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================================
  /// INSIGHT BLOCK
  /// ============================================================
  Widget _InsightBlock({
    required String title,
    required String subtitle,
    required String highlight,
    required Widget chart,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sectionTitle),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTheme.bodyMuted),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.card,
            height: 220,
            child: chart,
          ),

          const SizedBox(height: 8),
          Text(
            highlight,
            style: AppTheme.caption.copyWith(color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  /// ============================================================
  /// CHARTS
  /// ============================================================
  Widget _stepsChart() {
    final steps = [3500, 5000, 7000, 4500, 9500, 10000, 6000];
    return BarChart(
      BarChartData(
        maxY: 11000,
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: steps[i].toDouble(),
                color: AppTheme.primary,
                width: 10,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sleepMoodChart() {
    final sleep = [7, 6, 8, 5, 7, 6, 7];
    final mood = [3, 4, 2, 5, 3, 4, 4];

    return BarChart(
      BarChartData(
        maxY: 10,
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: sleep[i].toDouble(),
                color: AppTheme.info,
                width: 8,
              ),
              BarChartRodData(
                toY: mood[i].toDouble(),
                color: AppTheme.warning,
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _caloriesChart() {
    final intake = [2200, 1800, 2500, 2000, 2900, 3000, 2300];
    final burned = [500, 700, 800, 600, 1200, 1300, 900];

    return BarChart(
      BarChartData(
        maxY: 3500,
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: intake[i].toDouble(),
                color: AppTheme.primary,
                width: 8,
              ),
              BarChartRodData(
                toY: burned[i].toDouble(),
                color: AppTheme.success,
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  FlTitlesData _titles() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              days[v.toInt()],
              style: AppTheme.caption,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0D0D25);
    const labelColor = Color(0xFFEFEFFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Insights",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Track your progress and find patterns.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Weekly Steps Chart
              _buildSectionTitle("Weekly Steps"),
              _buildChartContainer(
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10000,
                    barGroups: _weeklyStepsData(),
                    borderData: FlBorderData(show: false),
                    titlesData: _buildTitles(),
                  ),
                ),
              ),

              // Sleep vs Mood Chart
              _buildSectionTitle("Sleep vs. Mood"),
              _buildChartContainer(
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10, // enough scale to fit sleep (8) + mood (5)
                    barGroups: _sleepMoodData(),
                    borderData: FlBorderData(show: false),
                    titlesData: _buildTitles(),
                  ),
                ),
              ),

              // Calorie Intake vs Burnout Chart
              _buildSectionTitle("Calorie Intake vs. Burnout"),
              _buildChartContainer(
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 3500,
                    barGroups: _caloriesBurnedData(),
                    borderData: FlBorderData(show: false),
                    titlesData: _buildTitles(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for chart titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEFEFFF),
        ),
      ),
    );
  }

  /// Helper widget for chart container styling
  Widget _buildChartContainer(Widget chart) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151533),
        borderRadius: BorderRadius.circular(12),
      ),
      child: chart,
    );
  }

  /// Common titles data (days of week)
  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Text(
              days[value.toInt()],
              style: const TextStyle(color: Colors.white70),
            );
          },
        ),
      ),
    );
  }

  /// Weekly steps (single bar per day)
  List<BarChartGroupData> _weeklyStepsData() {
    final steps = [3500, 5000, 7000, 4500, 9500, 10000, 6000];
    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: steps[i].toDouble(), color: Colors.purple),
        ],
      ),
    );
  }

  /// Sleep vs Mood (two bars side by side)
  List<BarChartGroupData> _sleepMoodData() {
    final sleep = [7, 6, 8, 5, 7, 6, 7]; // hours of sleep
    final mood = [3, 4, 2, 5, 3, 4, 4]; // mood ratings (1–5)

    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: sleep[i].toDouble(),
            color: Colors.cyan,
            width: 8,
          ),
          BarChartRodData(
            toY: mood[i].toDouble(),
            color: Colors.orange,
            width: 8,
          ),
        ],
      ),
    );
  }

  /// Calorie Intake vs Burnout (two bars side by side)
  List<BarChartGroupData> _caloriesBurnedData() {
    final intake = [2200, 1800, 2500, 2000, 2900, 3000, 2300];
    final burned = [500, 700, 800, 600, 1200, 1300, 900];

    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: intake[i].toDouble(),
            color: Colors.purple,
            width: 8,
          ),
          BarChartRodData(
            toY: burned[i].toDouble(),
            color: Colors.tealAccent,
            width: 8,
          ),
        ],
      ),
    );
  }
}

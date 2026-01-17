import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/tracker/ai_suggestion_card.dart';
import 'package:lumora/layouts/tracker/today_plan_card.dart';
import 'package:lumora/layouts/tracker/workout_checklist_page.dart';
import 'package:lumora/layouts/tracker/meal_checklist_page.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayLabel = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(
          "Daily Tracker",
          style: AppTheme.h2,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            /// ------------------------------------------------------------
            /// DATE CONTEXT
            /// ------------------------------------------------------------
            Text("Today", style: AppTheme.h1),
            const SizedBox(height: 4),
            Text(todayLabel, style: AppTheme.bodyMuted),

            const SizedBox(height: 20),

            /// ------------------------------------------------------------
            /// AI INSIGHT
            /// ------------------------------------------------------------
            const AISuggestionCard(
              message:
                  "You ate 20% healthier today than yesterday. Keep the momentum going 💪",
            ),

            const SizedBox(height: 28),

            /// ------------------------------------------------------------
            /// TODAY’S FOCUS
            /// ------------------------------------------------------------
            const _SectionHeader(
              title: "Your focus today",
              subtitle: "What matters most right now",
            ),

            const SizedBox(height: 12),

            /// ---------------- WORKOUT ----------------
            TodayPlanCard(
              title: "Upper Body Workout",
              subtitle: "45 min • 5 exercises",
              icon: Icons.fitness_center_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutChecklistPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            /// ---------------- MEALS ----------------
            TodayPlanCard(
              title: "Meal Plan",
              subtitle: "Breakfast • Lunch • Snack • Dinner",
              icon: Icons.restaurant_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MealChecklistPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            /// ------------------------------------------------------------
            /// DAILY SUMMARY
            /// ------------------------------------------------------------
            const _SectionHeader(
              title: "Daily summary",
              subtitle: "Calories, activity & recovery",
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.card,
              child: Text(
                "Daily calories, protein intake, steps, and recovery insights will appear here.",
                style: AppTheme.bodyMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// SECTION HEADER
/// ----------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.sectionTitle),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTheme.caption),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumora/layouts/tracker/ai_suggestion_card.dart';
import 'package:lumora/layouts/tracker/today_plan_card.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F1431);
    const textPrimary = Color(0xFFE9ECFF);
    const textMuted = Color(0xFFB7C0E0);

    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Tracker"),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// HEADER
            Text(
              "Today",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              today,
              style: const TextStyle(
                fontSize: 14,
                color: textMuted,
              ),
            ),

            const SizedBox(height: 20),

            /// AI SUGGESTION CARD
            const AISuggestionCard(
              message:
                  "You ate 20% healthier today than yesterday. Keep it up!",
            ),

            /// TODAY'S WORKOUT
            _sectionTitle("Today's Workout"),
            TodayPlanCard(
              title: "Upper Body Workout",
              subtitle: "45 min • 5 exercises",
              icon: Icons.fitness_center,
              onTap: () {
                // TODO: Navigate to WorkoutDetailScreen
                debugPrint("Navigate to workout details");
              },
            ),

            /// TODAY'S MEALS
            _sectionTitle("Today's Meals"),
            TodayPlanCard(
              title: "Meal Plan for Today",
              subtitle: "Breakfast • Lunch • Snack • Cheat Meal",
              icon: Icons.restaurant,
              onTap: () {
                // TODO: Navigate to MealDetailScreen
                debugPrint("Navigate to meal details");
              },
            ),

            /// DAILY SUMMARY (keep for later)
            _sectionTitle("Summary"),
            _placeholderCard(
              "Daily calories, protein, and activity summary",
            ),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE9ECFF),
        ),
      ),
    );
  }

  /// PLACEHOLDER CARD
  Widget _placeholderCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C315C)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB7C0E0),
        ),
      ),
    );
  }
}

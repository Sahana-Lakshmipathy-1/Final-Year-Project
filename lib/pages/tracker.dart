import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/layouts/tracker/ai_suggestion_card.dart';
import 'package:lumora/layouts/tracker/today_plan_card.dart';
import 'package:lumora/layouts/tracker/workout_checklist_page.dart';
import 'package:lumora/layouts/tracker/meal_checklist_page.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  // Data storage
  Map<String, dynamic>? _activeExerciseRoutine;
  Map<String, dynamic>? _activeMealRoutine;

  @override
  void initState() {
    super.initState();
    _fetchTodayData();
  }

  /// Fetches the latest routines from the backend
  Future<void> _fetchTodayData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.fetchExerciseRoutines(),
        _api.fetchMealRoutines(),
      ]);

      final exerciseData = results[0];
      final mealData = results[1];

      setState(() {
        // Simple logic: Pick the first available routine
        if (exerciseData['routines'] != null &&
            (exerciseData['routines'] as List).isNotEmpty) {
          _activeExerciseRoutine = exerciseData['routines'][0];
        }

        if (mealData['meals'] != null &&
            (mealData['meals'] as List).isNotEmpty) {
          _activeMealRoutine = mealData['meals'][0];
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching tracker data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Helper to get today's day name (e.g., "Monday")
  String _getTodayName() {
    return DateFormat('EEEE').format(DateTime.now());
  }

  /// Opens the Workout Checklist with REAL data
  void _openWorkoutChecklist() {
    if (_activeExerciseRoutine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No workout routine found! Create one first."),
        ),
      );
      return;
    }

    final String today = _getTodayName();
    final List schedule = _activeExerciseRoutine!['weekly_schedule'];

    // Find today's object index
    int dayIndex = schedule.indexWhere((day) => day['day'] == today);

    if (dayIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No workout scheduled for today!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutChecklistPage(
          dayData: schedule[dayIndex],
          dayIndex: dayIndex,
          routineId: _activeExerciseRoutine!['routine_id'],
          fullWeeklySchedule: schedule,
        ),
      ),
    ).then((_) => _fetchTodayData()); // Refresh progress when returning
  }

  /// Opens the Meal Checklist with REAL data
  void _openMealChecklist() {
    if (_activeMealRoutine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No meal plan found! Create one first.")),
      );
      return;
    }

    final String today = _getTodayName();
    final List weeklyMeals = _activeMealRoutine!['weekly_meals'];

    // Find today's object index
    int dayIndex = weeklyMeals.indexWhere((day) => day['day_name'] == today);

    if (dayIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No meals scheduled for today!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealChecklistPage(
          dayData: weeklyMeals[dayIndex],
          dayIndex: dayIndex,
          mealRoutineId: _activeMealRoutine!['meal_routine_id'],
          fullWeeklyMeals: weeklyMeals,
        ),
      ),
    ).then((_) => _fetchTodayData()); // Refresh progress when returning
  }

  @override
  Widget build(BuildContext context) {
    final todayLabel = DateFormat('EEEE, d MMM').format(DateTime.now());

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    // Dynamic Subtitles
    String workoutSubtitle = "No routine active";
    if (_activeExerciseRoutine != null) {
      // Logic to count exercises for today could go here
      workoutSubtitle = "Tap to view today's session";
    }

    String mealSubtitle = "No plan active";
    if (_activeMealRoutine != null) {
      mealSubtitle = "Tap to log your nutrition";
    }

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
        child: RefreshIndicator(
          onRefresh: _fetchTodayData,
          color: AppTheme.primary,
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
                title: _activeExerciseRoutine?['title'] ?? "Workout Routine",
                subtitle: workoutSubtitle,
                icon: Icons.fitness_center_rounded,
                onTap: _openWorkoutChecklist,
              ),

              const SizedBox(height: 14),

              /// ---------------- MEALS ----------------
              TodayPlanCard(
                title: _activeMealRoutine?['title'] ?? "Meal Plan",
                subtitle: mealSubtitle,
                icon: Icons.restaurant_rounded,
                onTap: _openMealChecklist,
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

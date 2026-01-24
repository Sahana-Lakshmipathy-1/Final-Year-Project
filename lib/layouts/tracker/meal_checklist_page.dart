import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/checklist_item.dart';
import 'package:lumora/services/api_service.dart';

class MealChecklistPage extends StatefulWidget {
  final Map<String, dynamic> dayData;
  final String mealRoutineId;
  final List<dynamic> fullWeeklyMeals;
  final int dayIndex;

  const MealChecklistPage({
    super.key,
    required this.dayData,
    required this.mealRoutineId,
    required this.fullWeeklyMeals,
    required this.dayIndex,
  });

  @override
  State<MealChecklistPage> createState() => _MealChecklistPageState();
}

class _MealChecklistPageState extends State<MealChecklistPage> {
  final ApiService _api = ApiService();

  // Local State (Mutable)
  late String _currentRoutineId;
  late List<dynamic> _currentWeeklyMeals;
  late List<dynamic> _meals; // The specific day's meals
  late String _currentDayTitle;

  // Dropdown Data
  List<dynamic> _availableRoutines = [];
  Map<String, dynamic>? _selectedRoutineOption;
  bool _isLoadingRoutines = true;

  @override
  void initState() {
    super.initState();
    // 1. Initialize local state from widget props
    _currentRoutineId = widget.mealRoutineId;
    _currentWeeklyMeals = widget.fullWeeklyMeals;
    _meals = widget.dayData['meals'] ?? [];
    _currentDayTitle = widget.dayData['day_name'] ?? "Meal Plan";

    // 2. Fetch all routines for the dropdown
    _fetchAllRoutines();
  }

  Future<void> _fetchAllRoutines() async {
    try {
      final response = await _api.fetchMealRoutines();
      final routines = response['meals'] ?? [];

      setState(() {
        _availableRoutines = routines;
        _isLoadingRoutines = false;

        // Try to set initial dropdown value to the current routine
        try {
          _selectedRoutineOption = routines.firstWhere(
            (r) => r['meal_routine_id'] == widget.mealRoutineId,
            orElse: () => routines.isNotEmpty ? routines[0] : null,
          );
        } catch (e) {
          if (routines.isNotEmpty) _selectedRoutineOption = routines[0];
        }
      });
    } catch (e) {
      print("Error fetching meal routines: $e");
      setState(() => _isLoadingRoutines = false);
    }
  }

  /// Logic to switch to a new meal plan dynamically
  void _switchRoutine(Map<String, dynamic> newRoutine) {
    final newWeeklyMeals = newRoutine['weekly_meals'] as List;

    // Safety Check: Ensure the new plan has this day index
    if (widget.dayIndex >= newWeeklyMeals.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This plan doesn't have data for this day."),
        ),
      );
      return;
    }

    // Get data for the SAME DAY from the NEW routine
    final newDayData = newWeeklyMeals[widget.dayIndex];

    setState(() {
      _selectedRoutineOption = newRoutine;
      _currentRoutineId = newRoutine['meal_routine_id'];
      _currentWeeklyMeals = newWeeklyMeals;
      _meals = newDayData['meals'] ?? [];
      _currentDayTitle = newDayData['day_name'] ?? "Meal Plan";
    });
  }

  /// Toggle completion and sync with DynamoDB
  Future<void> _toggleMeal(int index) async {
    String currentStatus = _meals[index]['completed'] ?? "No";
    String newStatus = (currentStatus == "Yes") ? "No" : "Yes";

    setState(() {
      _meals[index]['completed'] = newStatus;
    });

    // Clone and Update
    List<dynamic> updatedWeeklyMeals = List.from(_currentWeeklyMeals);
    var updatedDay = Map<String, dynamic>.from(
      updatedWeeklyMeals[widget.dayIndex],
    );

    updatedDay['meals'] = _meals;
    updatedWeeklyMeals[widget.dayIndex] = updatedDay;

    // Sync using the CURRENT routine ID
    try {
      await _api.updateMealRoutine(
        mealRoutineId: _currentRoutineId,
        updates: {"weekly_meals": updatedWeeklyMeals},
      );
      print("✅ Meal synced: $newStatus");
    } catch (e) {
      print("❌ Sync failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save progress")),
        );
      }
    }
  }

  /// Helper to get a displayable title from routine object
  String _getRoutineTitle(Map<String, dynamic> routine) {
    if (routine['title'] != null) return routine['title'];
    if (routine['plan_summary'] is String) return routine['plan_summary'];
    return "Untitled Plan";
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _meals.where((m) => m['completed'] == "Yes").length;
    final totalMeals = _meals.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentDayTitle, style: AppTheme.h2),
            if (_selectedRoutineOption != null)
              Text(
                _getRoutineTitle(_selectedRoutineOption!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          // 🚀 THE DROPDOWN
          if (!_isLoadingRoutines && _availableRoutines.isNotEmpty)
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: AppTheme.cardBg,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedRoutineOption,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primary,
                  ),
                  padding: const EdgeInsets.only(right: 16),
                  items: _availableRoutines.map((routine) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: routine,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          _getRoutineTitle(routine),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _switchRoutine(newValue);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$completedCount / $totalMeals logged",
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _meals.isEmpty
                  ? const Center(
                      child: Text(
                        "No meals logged for today",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _meals.length,
                      itemBuilder: (context, index) {
                        final item = _meals[index];

                        // Data Handling: Support both AI and Manual formats
                        String title =
                            item['description'] ?? item['name'] ?? "Meal";

                        String subtitle = "";
                        if (item['ingredients'] is List) {
                          subtitle = (item['ingredients'] as List)
                              .take(3)
                              .join(" • ");
                        } else if (item['ingredients'] is String) {
                          subtitle = item['ingredients'];
                        } else {
                          subtitle = item['meal_name'] ?? item['type'] ?? "";
                        }

                        final bool isDone = item['completed'] == "Yes";

                        return ChecklistItem(
                          title: title,
                          subtitle: subtitle,
                          completed: isDone,
                          onToggle: () => _toggleMeal(index),
                        );
                      },
                    ),
            ),

            ElevatedButton(
              style: AppTheme.primaryButton,
              onPressed: () => Navigator.pop(context),
              child: const Text("Save meals"),
            ),
          ],
        ),
      ),
    );
  }
}

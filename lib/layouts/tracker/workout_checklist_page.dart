import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/checklist_item.dart';
import 'package:lumora/services/api_service.dart';

class WorkoutChecklistPage extends StatefulWidget {
  final Map<String, dynamic> dayData;
  final String routineId;
  final List<dynamic> fullWeeklySchedule;
  final int dayIndex; // e.g., 0 for Monday

  const WorkoutChecklistPage({
    super.key,
    required this.dayData,
    required this.routineId,
    required this.fullWeeklySchedule,
    required this.dayIndex,
  });

  @override
  State<WorkoutChecklistPage> createState() => _WorkoutChecklistPageState();
}

class _WorkoutChecklistPageState extends State<WorkoutChecklistPage> {
  final ApiService _api = ApiService();

  // Local State (Mutable)
  late String _currentRoutineId;
  late List<dynamic> _currentSchedule;
  late List<dynamic> _exercises;
  late String _currentDayTitle;

  // Dropdown Data
  List<dynamic> _availableRoutines = [];
  Map<String, dynamic>? _selectedRoutineOption;
  bool _isLoadingRoutines = true;

  @override
  void initState() {
    super.initState();
    // 1. Initialize local state with the data passed from the previous screen
    _currentRoutineId = widget.routineId;
    _currentSchedule = widget.fullWeeklySchedule;
    _exercises = widget.dayData['exercises'] ?? [];
    _currentDayTitle = widget.dayData['day'] ?? "Workout";

    // 2. Fetch all routines so we can populate the dropdown
    _fetchAllRoutines();
  }

  Future<void> _fetchAllRoutines() async {
    try {
      final response = await _api.fetchExerciseRoutines();
      final routines = response['routines'] ?? [];

      setState(() {
        _availableRoutines = routines;
        _isLoadingRoutines = false;

        // Find the routine object that matches the one we started with
        // so the dropdown shows the correct initial value
        try {
          _selectedRoutineOption = routines.firstWhere(
            (r) => r['routine_id'] == widget.routineId,
            orElse: () => routines.isNotEmpty ? routines[0] : null,
          );
        } catch (e) {
          // Fallback if ID matching fails
          if (routines.isNotEmpty) _selectedRoutineOption = routines[0];
        }
      });
    } catch (e) {
      print("Error fetching routines: $e");
      setState(() => _isLoadingRoutines = false);
    }
  }

  /// Logic to switch the entire view to a new routine
  void _switchRoutine(Map<String, dynamic> newRoutine) {
    final newSchedule = newRoutine['weekly_schedule'] as List;

    // Safety Check: Ensure the new routine has the same day index
    // (e.g. if we are on Monday (index 0), ensure new routine has index 0)
    if (widget.dayIndex >= newSchedule.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This routine doesn't have this day.")),
      );
      return;
    }

    // Get the data for the SAME DAY from the NEW routine
    final newDayData = newSchedule[widget.dayIndex];

    setState(() {
      _selectedRoutineOption = newRoutine;
      _currentRoutineId = newRoutine['routine_id'];
      _currentSchedule = newSchedule;
      _exercises = newDayData['exercises'] ?? [];
      _currentDayTitle = newDayData['day'] ?? "Workout";
    });
  }

  /// Toggle completion and sync with DynamoDB
  Future<void> _toggleExercise(int index) async {
    String currentStatus = _exercises[index]['completed'] ?? "No";
    String newStatus = (currentStatus == "Yes") ? "No" : "Yes";

    setState(() {
      _exercises[index]['completed'] = newStatus;
    });

    // Clone and Update
    List<dynamic> updatedSchedule = List.from(_currentSchedule);
    var updatedDay = Map<String, dynamic>.from(
      updatedSchedule[widget.dayIndex],
    );

    updatedDay['exercises'] = _exercises;
    updatedSchedule[widget.dayIndex] = updatedDay;

    // Sync using the CURRENT routine ID
    try {
      await _api.updateExerciseRoutine(
        routineId: _currentRoutineId,
        updates: {"weekly_schedule": updatedSchedule},
      );
    } catch (e) {
      print("❌ Sync failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save progress")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _exercises
        .where((e) => e['completed'] == "Yes")
        .length;
    final totalExercises = _exercises.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentDayTitle, style: AppTheme.h2),
            // Show current routine name as subtitle
            if (_selectedRoutineOption != null)
              Text(
                _selectedRoutineOption?['title'] ?? "Current Routine",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          // 🚀 THE DROPDOWN
          if (!_isLoadingRoutines && _availableRoutines.isNotEmpty)
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: AppTheme.cardBg, // Dropdown background color
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
                      child: Text(
                        routine['title'] ?? "Routine",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
              "$completedCount / $totalExercises completed",
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _exercises.isEmpty
                  ? const Center(
                      child: Text(
                        "Rest Day / No Exercises",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final item = _exercises[index];
                        final String name = item['name'] ?? "Exercise";
                        final String sets = item['sets']?.toString() ?? "3";
                        final String reps = item['reps']?.toString() ?? "10";
                        final bool isDone = item['completed'] == "Yes";

                        return ChecklistItem(
                          title: name,
                          subtitle: "$sets sets • $reps reps",
                          completed: isDone,
                          onToggle: () => _toggleExercise(index),
                        );
                      },
                    ),
            ),

            ElevatedButton(
              style: AppTheme.primaryButton,
              onPressed: completedCount > 0
                  ? () => Navigator.pop(context)
                  : null,
              child: const Text("Finish Workout"),
            ),
          ],
        ),
      ),
    );
  }
}

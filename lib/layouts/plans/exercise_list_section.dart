import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/services/api_service.dart';

class ExerciseListSection extends StatefulWidget {
  const ExerciseListSection({super.key});

  @override
  State<ExerciseListSection> createState() => _ExerciseListSectionState();
}

class _ExerciseListSectionState extends State<ExerciseListSection> {
  final ApiService _api = ApiService();

  List<dynamic> _routines = [];
  Map<String, dynamic>? _selectedRoutine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Initial Fetch from API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.fetchExerciseRoutines();
      setState(() {
        _routines = response['routines'] ?? [];
        if (_routines.isNotEmpty) {
          _selectedRoutine = _routines.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Fetch Error: $e");
    }
  }

  /// Toggle completion of a specific exercise
  Future<void> _toggleExercise(int dayIndex, int exerciseIndex) async {
    if (_selectedRoutine == null) return;

    // 1. Create a deep copy of the schedule to modify
    List<dynamic> schedule = List.from(_selectedRoutine!['weekly_schedule']);
    var day = Map<String, dynamic>.from(schedule[dayIndex]);
    List<dynamic> exercises = List.from(day['exercises']);

    // 2. Flip the status
    String current = exercises[exerciseIndex]['completed'];
    exercises[exerciseIndex]['completed'] = (current == "Yes") ? "No" : "Yes";

    // 3. Update local state for instant feedback
    day['exercises'] = exercises;
    schedule[dayIndex] = day;

    setState(() {
      _selectedRoutine!['weekly_schedule'] = schedule;
    });

    // 4. Persist to Backend
    try {
      await _api.updateExerciseRoutine(
        routineId: _selectedRoutine!['routine_id'],
        updates: {"weekly_schedule": schedule},
      );
    } catch (e) {
      debugPrint("Update failed: $e");
      // Optional: Revert state if API fails
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Exercise List", style: AppTheme.sectionTitle),
            IconButton(
              icon: const Icon(
                LucideIcons.refreshCw,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: _fetchData,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text("Manage your weekly workout routine.", style: AppTheme.caption),
        const SizedBox(height: 14),

        /// 1. ROUTINE SELECTOR
        if (_routines.isNotEmpty) _buildRoutineSelector(),

        const SizedBox(height: 20),

        /// 2. WEEKLY SCHEDULE LIST
        if (_selectedRoutine != null)
          ...(_selectedRoutine!['weekly_schedule'] as List).asMap().entries.map(
            (entry) {
              int dayIdx = entry.key;
              var dayData = entry.value;
              return _buildDayTile(dayData, dayIdx);
            },
          ),

        if (_routines.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "No routines found. Generate one with AI!",
                style: AppTheme.caption,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRoutineSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedRoutine,
          isExpanded: true,
          dropdownColor: AppTheme.cardBg,
          items: _routines.map((dynamic routine) {
            final routineMap = routine as Map<String, dynamic>;

            // 🚀 UPDATED LOGIC: Prioritize 'title'
            String label =
                routineMap['title'] ??
                routineMap['routine_summary']?.toString().split('.').first ??
                "Untitled Routine";

            return DropdownMenuItem<Map<String, dynamic>>(
              value: routineMap,
              child: Text(
                label,
                style: AppTheme.body,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedRoutine = v),
        ),
      ),
    );
  }

  Widget _buildDayTile(Map<String, dynamic> dayData, int dayIdx) {
    final List exercises = dayData['exercises'] ?? [];
    final String dayName = dayData['day'] ?? "Unknown";

    // Check if all exercises in this day are done
    bool isDayComplete =
        exercises.isNotEmpty && exercises.every((e) => e['completed'] == "Yes");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: AppTheme.radiusMedium,
        border: isDayComplete
            ? Border.all(color: AppTheme.primary.withOpacity(0.5))
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            isDayComplete ? LucideIcons.checkCircle2 : LucideIcons.calendarDays,
            color: isDayComplete ? AppTheme.primary : Colors.grey,
          ),
          title: Text(dayName, style: AppTheme.h3),
          subtitle: Text(
            "${exercises.length} Exercises",
            style: AppTheme.caption,
          ),
          children: [
            ...exercises.asMap().entries.map((exEntry) {
              int exIdx = exEntry.key;
              var ex = exEntry.value;
              return _buildExerciseItem(
                ex['name'] ?? "Exercise",
                "${ex['sets'] ?? 0} sets • ${ex['reps'] ?? 0} reps",
                ex['completed'] == "Yes",
                () => _toggleExercise(dayIdx, exIdx),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(
    String name,
    String subtitle,
    bool done,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              done ? LucideIcons.checkSquare : LucideIcons.square,
              size: 20,
              color: done ? AppTheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.body.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? Colors.grey : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

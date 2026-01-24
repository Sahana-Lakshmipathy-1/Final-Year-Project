import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/services/api_service.dart';

class MealListSection extends StatefulWidget {
  const MealListSection({super.key});

  @override
  State<MealListSection> createState() => _MealListSectionState();
}

class _MealListSectionState extends State<MealListSection> {
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
      final response = await _api.fetchMealRoutines();
      setState(() {
        _routines = response['meals'] ?? [];
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

  /// Toggle completion of a specific meal
  Future<void> _toggleMeal(int dayIndex, int mealIndex) async {
    if (_selectedRoutine == null) return;

    // 1. Deep copy the nested structure
    List<dynamic> weeklyMeals = List.from(_selectedRoutine!['weekly_meals']);
    var day = Map<String, dynamic>.from(weeklyMeals[dayIndex]);
    List<dynamic> meals = List.from(day['meals']);

    // 2. Flip the status
    String current = meals[mealIndex]['completed'] ?? "No";
    meals[mealIndex]['completed'] = (current == "Yes") ? "No" : "Yes";

    // 3. Update local state
    day['meals'] = meals;
    weeklyMeals[dayIndex] = day;

    setState(() {
      _selectedRoutine!['weekly_meals'] = weeklyMeals;
    });

    // 4. Persist to Backend
    try {
      await _api.updateMealRoutine(
        mealRoutineId: _selectedRoutine!['meal_routine_id'],
        updates: {"weekly_meals": weeklyMeals},
      );
    } catch (e) {
      debugPrint("Update failed: $e");
      _fetchData(); // Revert on error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Meal Plan", style: AppTheme.sectionTitle),
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
        Text("Track your daily nutrition and meals.", style: AppTheme.caption),
        const SizedBox(height: 14),

        /// 1. ROUTINE SELECTOR
        if (_routines.isNotEmpty) _buildRoutineSelector(),

        const SizedBox(height: 20),

        /// 2. WEEKLY MEAL LIST
        if (_selectedRoutine != null)
          ...(_selectedRoutine!['weekly_meals'] as List).asMap().entries.map((
            entry,
          ) {
            int dayIdx = entry.key;
            var dayData = entry.value;
            return _buildDayTile(dayData, dayIdx);
          }),

        if (_routines.isEmpty)
          const Center(
            child: Text(
              "No meal plans found.",
              style: TextStyle(color: Colors.grey),
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
            final rMap = routine as Map<String, dynamic>;

            // 🚀 UPDATED LOGIC: Prioritize 'title'
            String label;
            if (rMap['title'] != null && rMap['title'].toString().isNotEmpty) {
              label = rMap['title'];
            } else if (rMap['plan_summary'] is String) {
              label = rMap['plan_summary']; // Manual Plan fallback
            } else {
              // AI Plan fallback (if title is missing)
              label = rMap['plan_summary']?['personal_notes'] ?? "Meal Plan";
            }

            return DropdownMenuItem<Map<String, dynamic>>(
              value: rMap,
              child: Text(
                label.length > 30 ? "${label.substring(0, 30)}..." : label,
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
    final List meals = dayData['meals'] ?? [];
    final String dayName = dayData['day_name'] ?? "Unknown";

    bool isDayComplete =
        meals.isNotEmpty && meals.every((m) => m['completed'] == "Yes");

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
            isDayComplete ? LucideIcons.checkCircle2 : LucideIcons.utensils,
            color: isDayComplete ? AppTheme.primary : Colors.grey,
          ),
          title: Text(dayName, style: AppTheme.h3),
          subtitle: Text("${meals.length} Meals", style: AppTheme.caption),
          children: [
            ...meals.asMap().entries.map((mEntry) {
              return _buildMealItem(
                mEntry.value,
                () => _toggleMeal(dayIdx, mEntry.key),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal, VoidCallback onTap) {
    bool done = meal['completed'] == "Yes";

    // 🛡️ Data Normalization
    String foodName = meal['description'] ?? meal['name'] ?? "Meal";
    String mealType = meal['meal_name'] ?? meal['type'] ?? "Snack";

    List ingredients = meal['ingredients'] ?? [];
    String subText = ingredients.isNotEmpty
        ? ingredients.take(3).join(", ")
        : mealType;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                done ? LucideIcons.checkSquare : LucideIcons.square,
                size: 20,
                color: done ? AppTheme.primary : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: AppTheme.body.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? Colors.grey : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: AppTheme.captionSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal['calories'] != null)
                    Text(
                      "${meal['calories']} kcal",
                      style: AppTheme.caption.copyWith(color: AppTheme.primary),
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

import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

class ManualMealSetupScreen extends StatefulWidget {
  const ManualMealSetupScreen({super.key});

  @override
  State<ManualMealSetupScreen> createState() => _ManualMealSetupScreenState();
}

class _ManualMealSetupScreenState extends State<ManualMealSetupScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _planNameController = TextEditingController();
  bool _isLoading = false;

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> weeklyMeals = [];

  @override
  void initState() {
    super.initState();
    // Initialize structure
    for (final d in days) {
      weeklyMeals.add({
        'day_name': d,
        'meals': <Map<String, dynamic>>[],
      });
    }
  }

  Future<void> _savePlan() async {
    if (_planNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please name your plan (e.g. Carb Cycle)"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. TRANSFORM DATA
      // We need to calculate total_calories for each day and ensure types are correct
      List<Map<String, dynamic>> finalWeeklySchedule = weeklyMeals.map((day) {
        int totalCals = 0;
        List<Map<String, dynamic>> meals = (day['meals'] as List).map((m) {
          int cals = int.tryParse(m['calories'].toString()) ?? 0;
          totalCals += cals;

          return {
            "type": m['type'], // breakfast, lunch, etc.
            "name": m['name'],
            "calories": cals,
            "protein": int.tryParse(m['protein'].toString()) ?? 0,
            "carbs": int.tryParse(m['carbs'].toString()) ?? 0,
            "fats": int.tryParse(m['fats'].toString()) ?? 0,
            "ingredients": m['ingredients'], // List<String>
            "completed": "No", // ✅ CRITICAL: Default status for tracking
          };
        }).toList();

        return {
          "day_name": day['day_name'].toString(),
          "total_calories": totalCals,
          "meals": meals,
        };
      }).toList();

      // 2. CONSTRUCT PAYLOAD
      final payload = {
        "event_type": "create_manual_meal_plan",
        "user_id": UserSession.email,
        // ✅ NEW FIELD: Sending 'title' explicitly so it shows up in your Dropdown
        "title": _planNameController.text.trim(),
        "plan_summary": "Manual Plan: ${_planNameController.text.trim()}",
        "weekly_meals": finalWeeklySchedule,
      };

      print("🚀 Sending Meal Plan Payload: $payload");

      // 3. SEND TO API
      // Ensure ApiService has createManualMealPlan method wired to _post
      await _api.createManualMealPlan(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meal Plan Created Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to list screen
      }
    } catch (e) {
      print("❌ Error saving plan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.error, // Assuming AppTheme.error exists
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Create Meal Plan'),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _savePlan,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- TOP BAR: PLAN NAME ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _planNameController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Plan Name (e.g. High Protein Week 1)',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 20),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // --- SCROLLABLE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: weeklyMeals.length,
              itemBuilder: (context, index) {
                return _DayCard(
                  dayData: weeklyMeals[index],
                  onUpdate: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── DAY CARD ─────────────────
class _DayCard extends StatelessWidget {
  final Map<String, dynamic> dayData;
  final VoidCallback onUpdate;

  const _DayCard({required this.dayData, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    List meals = dayData['meals'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARD HEADER ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(dayData['day_name'], style: AppTheme.h3),
          ),

          // --- MEALS LIST ---
          if (meals.isNotEmpty) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: meals.map<Widget>((meal) {
                  final index = meals.indexOf(meal);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < meals.length - 1 ? 12 : 0,
                    ),
                    child: _MealEditor(
                      meal: meal,
                      onRemove: () {
                        dayData['meals'].remove(meal);
                        onUpdate();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // --- ADD MEAL BUTTON ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: AppTheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.add,
                  color: AppTheme.primary,
                  size: 20,
                ),
                label: const Text(
                  "Add Meal",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  dayData['meals'].add({
                    'type': 'breakfast',
                    'name': '',
                    'calories': '',
                    'protein': '',
                    'carbs': '',
                    'fats': '',
                    'ingredients': <String>[],
                  });
                  onUpdate();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── MEAL EDITOR ─────────────────
class _MealEditor extends StatefulWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onRemove;

  const _MealEditor({required this.meal, required this.onRemove});

  @override
  State<_MealEditor> createState() => _MealEditorState();
}

class _MealEditorState extends State<_MealEditor> {
  final _ingredientController = TextEditingController();

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        widget.meal['ingredients'].add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Type + Name + Remove
          Row(
            children: [
              // Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.meal['type'],
                    dropdownColor: AppTheme.cardBg,
                    isDense: true,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    items: ['breakfast', 'lunch', 'dinner', 'snack']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => widget.meal['type'] = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name Input
              Expanded(
                child: TextFormField(
                  initialValue: widget.meal['name'],
                  onChanged: (v) => widget.meal['name'] = v,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Meal Name (e.g. Oats)",
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onRemove,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Macros
          Row(
            children: [
              _buildMacroInput("Cal", "calories"),
              const SizedBox(width: 10),
              _buildMacroInput("Prot", "protein"),
              const SizedBox(width: 10),
              _buildMacroInput("Carb", "carbs"),
              const SizedBox(width: 10),
              _buildMacroInput("Fat", "fats"),
            ],
          ),

          const SizedBox(height: 16),

          // Row 3: Ingredients Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ingredients List
                if ((widget.meal['ingredients'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (widget.meal['ingredients'] as List).map<Widget>((
                      ing,
                    ) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ing,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => setState(
                                () => widget.meal['ingredients'].remove(ing),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Add Ingredient Input
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 16,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Add ingredient (e.g. Eggs)",
                          hintStyle: TextStyle(
                            color: Colors.white24,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    InkWell(
                      onTap: _addIngredient,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add_circle,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInput(String label, String key) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: widget.meal[key].toString(),
              onChanged: (v) => widget.meal[key] = v,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

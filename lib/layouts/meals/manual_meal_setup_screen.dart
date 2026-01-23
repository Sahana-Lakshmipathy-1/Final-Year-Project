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
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. TRANSFORM DATA
      // We need to calculate total_calories for each day
      List<Map<String, dynamic>> finalWeeklySchedule = weeklyMeals.map((day) {
        int totalCals = 0;
        List<Map<String, dynamic>> meals = (day['meals'] as List).map((m) {
          int cals = int.tryParse(m['calories'].toString()) ?? 0;
          totalCals += cals;

          return {
            "type": m['type'],
            "name": m['name'],
            "calories": cals,
            "protein": int.tryParse(m['protein'].toString()) ?? 0,
            "carbs": int.tryParse(m['carbs'].toString()) ?? 0,
            "fats": int.tryParse(m['fats'].toString()) ?? 0,
            "ingredients": m['ingredients'], // List<String>
            "completed": "No", // ✅ ADDED DEFAULT
          };
        }).toList();

        return {
          "day_name": day['day_name'].toString().toLowerCase(),
          "total_calories": totalCals,
          "meals": meals,
        };
      }).toList();

      // 2. CONSTRUCT PAYLOAD
      final payload = {
        "event_type": "create_manual_meal_plan",
        "user_id": UserSession.email, // ✅ Session
        "plan_summary": _planNameController.text,
        "weekly_meals": finalWeeklySchedule,
      };

      print("🚀 Sending Meal Plan: $payload");

      // 3. SEND TO API
      await _api.createManualMealPlan(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meal Plan Created Successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.danger,
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _planNameController,
              style: AppTheme.h2,
              decoration: AppTheme.inputDecoration(
                'Plan Name (e.g. Keto Week 1)',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.bg,
        child: ElevatedButton(
          style: AppTheme.primaryButton,
          onPressed: _isLoading ? null : _savePlan,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save Meal Plan"),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayData['day_name'], style: AppTheme.h3),
          const SizedBox(height: 12),

          // Existing Meals
          ...(dayData['meals'] as List).map((meal) {
            return _MealEditor(
              meal: meal,
              onRemove: () {
                dayData['meals'].remove(meal);
                onUpdate();
              },
            );
          }),

          const SizedBox(height: 12),

          // Add Meal Button
          OutlinedButton.icon(
            style: AppTheme.ghostButton,
            icon: const Icon(Icons.add),
            label: const Text("Add Meal"),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Type + Name + Remove
          Row(
            children: [
              // Type Dropdown
              DropdownButton<String>(
                value: widget.meal['type'],
                dropdownColor: AppTheme.cardBg,
                underline: Container(),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(width: 12),
              // Name Input
              Expanded(
                child: TextFormField(
                  initialValue: widget.meal['name'],
                  onChanged: (v) => widget.meal['name'] = v,
                  style: AppTheme.body,
                  decoration: const InputDecoration(
                    hintText: "Meal Name (e.g. Oats)",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const Divider(),

          // Row 2: Macros
          Row(
            children: [
              _buildMacroInput("Cal", "calories"),
              const SizedBox(width: 8),
              _buildMacroInput("Prot", "protein"),
              const SizedBox(width: 8),
              _buildMacroInput("Carb", "carbs"),
              const SizedBox(width: 8),
              _buildMacroInput("Fat", "fats"),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Ingredients List
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (widget.meal['ingredients'] as List).map<Widget>((ing) {
              return Chip(
                label: Text(ing, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppTheme.bg,
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    setState(() => widget.meal['ingredients'].remove(ing)),
              );
            }).toList(),
          ),

          // Row 4: Add Ingredient
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  style: AppTheme.body,
                  decoration: const InputDecoration(
                    hintText: "Add ingredient (e.g. Eggs)",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addIngredient(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                onPressed: _addIngredient,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInput(String label, String key) {
    return Expanded(
      child: TextFormField(
        initialValue: widget.meal[key].toString(),
        onChanged: (v) => widget.meal[key] = v,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}

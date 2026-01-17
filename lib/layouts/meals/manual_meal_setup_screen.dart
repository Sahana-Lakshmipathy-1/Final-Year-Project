import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class ManualMealSetupScreen extends StatefulWidget {
  const ManualMealSetupScreen({super.key});

  @override
  State<ManualMealSetupScreen> createState() => _ManualMealSetupScreenState();
}

class _ManualMealSetupScreenState extends State<ManualMealSetupScreen> {
  final days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> routine = [];

  @override
  void initState() {
    super.initState();
    for (final d in days) {
      routine.add({
        'day': d,
        'meals': <Map<String, dynamic>>[],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Manual Meal Plan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routine.length,
        itemBuilder: (context, index) {
          final day = routine[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.card,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DAY TITLE
                Text(day['day'], style: AppTheme.h2),
                const SizedBox(height: 12),

                /// MEALS
                ...day['meals'].map<Widget>((meal) {
                  return _MealEditor(
                    meal: meal,
                    onRemove: () => setState(() => day['meals'].remove(meal)),
                  );
                }).toList(),

                /// ADD MEAL
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                  style: AppTheme.ghostButton,
                  onPressed: () {
                    setState(() {
                      day['meals'].add({
                        'name': 'Breakfast',
                        'time': null,
                        'items': <Map<String, dynamic>>[],
                      });
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),

      /// SAVE CTA
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: AppTheme.primaryButton,
          onPressed: () => Navigator.pop(context, routine),
          child: const Text('Save Meal Routine'),
        ),
      ),
    );
  }
}

/// ───────────────── MEAL EDITOR ─────────────────

class _MealEditor extends StatefulWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onRemove;

  const _MealEditor({
    required this.meal,
    required this.onRemove,
  });

  @override
  State<_MealEditor> createState() => _MealEditorState();
}

class _MealEditorState extends State<_MealEditor> {
  final foodCtrl = TextEditingController();
  final gramCtrl = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.meal['time'] != null) {
      final p = widget.meal['time'].split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(p[0]),
        minute: int.parse(p[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.meal['name'],
                  items:
                      const [
                            'Breakfast',
                            'Lunch',
                            'Snack',
                            'Cheat Meal',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => widget.meal['name'] = v),
                  decoration: const InputDecoration(
                    labelText: 'Meal Type',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: AppTheme.textMuted,
                onPressed: widget.onRemove,
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// TIME PICKER
          Row(
            children: [
              Text("Meal Time", style: AppTheme.bodyMuted),
              const SizedBox(width: 12),
              Text(
                selectedTime == null
                    ? "Not set"
                    : selectedTime!.format(context),
                style: AppTheme.body,
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (t != null) {
                    setState(() {
                      selectedTime = t;
                      widget.meal['time'] =
                          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                    });
                  }
                },
                child: const Text("Pick"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// FOOD ITEMS
          ...widget.meal['items'].map<Widget>((item) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item['food'], style: AppTheme.body),
              subtitle: Text('${item['grams']} g', style: AppTheme.caption),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.textMuted,
                onPressed: () =>
                    setState(() => widget.meal['items'].remove(item)),
              ),
            );
          }).toList(),

          /// ADD FOOD
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: foodCtrl,
                  decoration: const InputDecoration(labelText: 'Food'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: gramCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'g'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: AppTheme.primary,
                onPressed: () {
                  if (foodCtrl.text.isNotEmpty && gramCtrl.text.isNotEmpty) {
                    setState(() {
                      widget.meal['items'].add({
                        'food': foodCtrl.text,
                        'grams': int.parse(gramCtrl.text),
                      });
                      foodCtrl.clear();
                      gramCtrl.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

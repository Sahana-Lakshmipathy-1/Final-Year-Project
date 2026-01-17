import 'package:flutter/material.dart';

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
    const bg = Color(0xFF0F1431);
    const card = Color(0xFF181C3A);
    const edge = Color(0xFF2C315C);
    const accent = Color(0xFFB787FF);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Manual Meal Routine'),
        backgroundColor: card,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routine.length,
        itemBuilder: (context, index) {
          final day = routine[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: edge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DAY HEADER
                Text(
                  day['day'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),

                const SizedBox(height: 12),

                /// MEALS
                ...day['meals'].map<Widget>((meal) {
                  return _MealEditor(
                    meal: meal,
                    onRemove: () => setState(() => day['meals'].remove(meal)),
                  );
                }).toList(),

                /// ADD MEAL
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent),
                  ),
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

      /// SAVE
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.pop(context, routine);
          },
          child: const Text(
            'Save Meal Routine',
            style: TextStyle(
              color: Color(0xFF1A1034),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

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
      selectedTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
  }

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFB7C0E0);
    const accent = Color(0xFFB787FF);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF14183A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// MEAL NAME + REMOVE
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
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => widget.meal['name'] = v),
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: muted),
                onPressed: widget.onRemove,
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// TIME PICKER
          Row(
            children: [
              const Text("Meal Time", style: TextStyle(color: muted)),
              const SizedBox(width: 12),
              Text(
                selectedTime == null
                    ? "Not set"
                    : selectedTime!.format(context),
              ),
              const Spacer(),
              TextButton(
                child: const Text("Pick"),
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
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// FOOD LIST
          ...widget.meal['items'].map<Widget>((item) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item['food']),
              subtitle: Text('${item['grams']} g'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
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
                icon: const Icon(Icons.add, color: accent),
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

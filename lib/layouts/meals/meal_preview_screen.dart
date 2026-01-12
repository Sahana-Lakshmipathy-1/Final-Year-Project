import 'package:flutter/material.dart';

class MealPreviewScreen extends StatefulWidget {
  const MealPreviewScreen({super.key});

  @override
  State<MealPreviewScreen> createState() => _MealPreviewScreenState();
}

class _MealPreviewScreenState extends State<MealPreviewScreen> {
  final List<Map<String, dynamic>> meals = [
    {
      'id': 1,
      'title': 'Vegetable Oats Upma',
      'icon': '🥣',
      'mealType': 'Breakfast',
      'tags': ['Vegetarian', 'High Fiber', 'Easy'],
      'calories': '350 kcal',
      'description':
          'A nutritious oats-based breakfast loaded with vegetables for sustained energy.',
      'selected': true,
    },
    {
      'id': 2,
      'title': 'Grilled Paneer Bowl',
      'icon': '🧀',
      'mealType': 'Lunch',
      'tags': ['High Protein', 'Vegetarian', 'Balanced'],
      'calories': '520 kcal',
      'description':
          'Grilled paneer served with brown rice and sautéed vegetables.',
      'selected': true,
    },
    {
      'id': 3,
      'title': 'Fruit & Nut Yogurt',
      'icon': '🍓',
      'mealType': 'Snack',
      'tags': ['Quick', 'Probiotic', 'Light'],
      'calories': '220 kcal',
      'description':
          'Fresh fruits mixed with yogurt and nuts for a light, refreshing snack.',
      'selected': true,
    },
    {
      'id': 4,
      'title': 'Dal, Roti & Veg Curry',
      'icon': '🍛',
      'mealType': 'Dinner',
      'tags': ['Vegetarian', 'Balanced', 'Comfort'],
      'calories': '480 kcal',
      'description':
          'A classic Indian dinner with dal, whole wheat roti, and seasonal vegetables.',
      'selected': false,
    },
  ];

  void toggleMeal(int id) {
    setState(() {
      final i = meals.indexWhere((m) => m['id'] == id);
      meals[i]['selected'] = !meals[i]['selected'];
    });
  }

  void addAll() => setState(() => meals.forEach((m) => m['selected'] = true));
  void clearAll() =>
      setState(() => meals.forEach((m) => m['selected'] = false));

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1431);
    const card = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const muted = Color(0xFFB7C0E0);
    const success = Color(0xFF4ADE80);
    const edge = Color(0xFF2C315C);

    final selectedCount = meals.where((m) => m['selected']).length;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Meal Plan ✨',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$selectedCount meals',
                      style: const TextStyle(
                        color: Color(0xFF1A1034),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Review and customize your AI-generated meals. Drag to reorder, toggle to add/remove.',
                style: TextStyle(color: muted, fontSize: 13),
              ),

              const SizedBox(height: 14),

              /// QUICK ACTIONS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF23275F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: edge),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _chip('Add All', accent, Colors.black, addAll),
                    const SizedBox(width: 8),
                    _chip(
                      'Clear All',
                      Colors.transparent,
                      Colors.redAccent,
                      clearAll,
                      border: Colors.redAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// MEAL LIST
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: meals.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = meals.removeAt(oldIndex);
                      meals.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final m = meals[index];
                    return ListTile(
                      key: ValueKey(m['id']),
                      contentPadding: EdgeInsets.zero,
                      title: _MealCard(
                        meal: m,
                        onToggle: () => toggleMeal(m['id']),
                      ),
                      trailing: const Icon(
                        Icons.drag_handle_rounded,
                        color: muted,
                      ),
                    );
                  },
                ),
              ),

              /// FOOTER BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Confirm & Continue',
                        style: TextStyle(
                          color: Color(0xFF1A1034),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF242953),
                        side: const BorderSide(color: Color(0xFF3A3F72)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    Color bg,
    Color color,
    VoidCallback onTap, {
    Color? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border ?? Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}

/// ---------------- MEAL CARD ----------------

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onToggle;

  const _MealCard({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFB7C0E0);
    const success = Color(0xFF4ADE80);
    const edge = Color(0xFF2C315C);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF23275F), Color(0xFF181B40)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: meal['selected'] ? success : edge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF14183A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(meal['icon'], style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(meal['mealType'], Colors.orangeAccent),
                    ...meal['tags'].map<Widget>(
                      (t) => _tag(t, muted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  meal['description'],
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  meal['calories'],
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          /// TOGGLE
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: meal['selected'] ? success : const Color(0xFF14183A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                meal['selected'] ? Icons.check_rounded : Icons.add_rounded,
                color: meal['selected'] ? const Color(0xFF1A1034) : muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262B56),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

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
          'Nutritious oats breakfast with vegetables for sustained energy.',
      'selected': true,
    },
    {
      'id': 2,
      'title': 'Grilled Paneer Bowl',
      'icon': '🧀',
      'mealType': 'Lunch',
      'tags': ['High Protein', 'Balanced'],
      'calories': '520 kcal',
      'description': 'Grilled paneer with brown rice and sautéed vegetables.',
      'selected': true,
    },
    {
      'id': 3,
      'title': 'Fruit & Nut Yogurt',
      'icon': '🍓',
      'mealType': 'Snack',
      'tags': ['Quick', 'Light'],
      'calories': '220 kcal',
      'description': 'Fresh fruits mixed with yogurt and nuts.',
      'selected': true,
    },
    {
      'id': 4,
      'title': 'Dal, Roti & Veg Curry',
      'icon': '🍛',
      'mealType': 'Dinner',
      'tags': ['Comfort', 'Balanced'],
      'calories': '480 kcal',
      'description': 'Classic Indian dinner with dal, roti and vegetables.',
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
    final selectedCount = meals.where((m) => m['selected']).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Your Meal Plan"),
      ),
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
                  Text("Review Meals ✨", style: AppTheme.h1),
                  _countBadge("$selectedCount meals"),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Customize your AI-generated meals. Toggle or reorder as needed.",
                style: AppTheme.bodyMuted,
              ),

              const SizedBox(height: 16),

              /// QUICK ACTIONS
              Container(
                decoration: AppTheme.card,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text("Quick actions", style: AppTheme.body),
                    const Spacer(),
                    _actionChip("Add all", AppTheme.primary, addAll),
                    const SizedBox(width: 8),
                    _actionChip(
                      "Clear",
                      AppTheme.danger,
                      clearAll,
                      outline: true,
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
                    final meal = meals[index];
                    return ListTile(
                      key: ValueKey(meal['id']),
                      contentPadding: EdgeInsets.zero,
                      title: _MealCard(
                        meal: meal,
                        onToggle: () => toggleMeal(meal['id']),
                      ),
                      trailing: const Icon(
                        Icons.drag_handle_rounded,
                        color: AppTheme.textMuted,
                      ),
                    );
                  },
                ),
              ),

              /// FOOTER CTA
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: AppTheme.ghostButton,
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: AppTheme.primaryButton,
                      onPressed: () {},
                      child: const Text("Confirm & Continue"),
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

  /// ───────── UI HELPERS ─────────

  Widget _countBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: AppTheme.bg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionChip(
    String label,
    Color color,
    VoidCallback onTap, {
    bool outline = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color.withOpacity(0.15),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTheme.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ───────────────── MEAL CARD ─────────────────

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onToggle;

  const _MealCard({
    required this.meal,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = meal['selected'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.cardBgAlt,
            AppTheme.cardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: selected ? AppTheme.success : AppTheme.borderSoft,
        ),
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
              color: AppTheme.cardBgAlt,
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Text(meal['icon'], style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal['title'], style: AppTheme.h2),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(meal['mealType'], AppTheme.warning),
                    ...meal['tags'].map<Widget>(
                      (t) => _tag(t, AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(meal['description'], style: AppTheme.bodyMuted),
                const SizedBox(height: 4),
                Text(
                  meal['calories'],
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.success,
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
                color: selected ? AppTheme.success : AppTheme.cardBgAlt,
                borderRadius: AppTheme.radiusSmall,
              ),
              child: Icon(
                selected ? Icons.check_rounded : Icons.add_rounded,
                color: selected ? AppTheme.bg : AppTheme.textMuted,
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
        color: AppTheme.cardBgAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

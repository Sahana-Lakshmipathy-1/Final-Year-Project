import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class SavedMealsPreview extends StatelessWidget {
  const SavedMealsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final weekMeals = [
      {
        'day': 'Monday',
        'type': 'Balanced',
        'calories': '1,800 kcal',
        'meals': [
          {
            'icon': '🥣',
            'name': 'Vegetable Oats Upma',
            'meta': 'Breakfast • 350 kcal',
          },
          {
            'icon': '🧀',
            'name': 'Grilled Paneer Bowl',
            'meta': 'Lunch • 520 kcal',
          },
          {
            'icon': '🍓',
            'name': 'Fruit & Nut Yogurt',
            'meta': 'Snack • 220 kcal',
          },
          {
            'icon': '🍛',
            'name': 'Dal, Roti & Veg Curry',
            'meta': 'Dinner • 480 kcal',
          },
        ],
      },
      {
        'day': 'Tuesday',
        'type': 'High Protein',
        'calories': '1,950 kcal',
        'meals': [
          {
            'icon': '🍳',
            'name': 'Paneer Bhurji & Toast',
            'meta': 'Breakfast • 400 kcal',
          },
          {'icon': '🍚', 'name': 'Rajma Rice', 'meta': 'Lunch • 560 kcal'},
          {
            'icon': '🥛',
            'name': 'Protein Smoothie',
            'meta': 'Snack • 250 kcal',
          },
          {
            'icon': '🥗',
            'name': 'Mixed Veg Salad',
            'meta': 'Dinner • 420 kcal',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Meal Plan"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              /// AI TWEAKS
              Container(
                decoration: AppTheme.card,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI Tweaks", style: AppTheme.caption),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          _TweakChip("🔥 Increase protein"),
                          _TweakChip("🥗 More vegetables"),
                          _TweakChip("⚖️ Lower calories"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// WEEKLY DAYS
              ...weekMeals.map((day) => _MealDayCard(day)).toList(),
            ],
          ),

          /// FLOATING ADD
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppTheme.primary,
              onPressed: () {},
              child: Icon(Icons.add, color: AppTheme.bg),
            ),
          ),
        ],
      ),

      /// BOTTOM ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: AppTheme.borderSoft)),
        ),
        child: Row(
          children: [
            _secondaryButton("🔀 Shuffle"),
            const SizedBox(width: 8),
            _secondaryButton("💾 Save"),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () {},
                child: const Text("🍽 Start Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton(String label) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cardBgAlt,
          foregroundColor: AppTheme.textWhite,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {},
        child: Text(label, style: AppTheme.caption),
      ),
    );
  }
}

/// ───────────────── DAY CARD ─────────────────

class _MealDayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  const _MealDayCard(this.day);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.elevatedCard,
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(day['day'], style: AppTheme.h2),
                    const SizedBox(width: 8),
                    _pill(day['type']),
                  ],
                ),
                Text(day['calories'], style: AppTheme.caption),
              ],
            ),
          ),

          /// MEALS
          ...day['meals'].map<Widget>((meal) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cardBgAlt,
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: Text(meal['icon'], style: const TextStyle(fontSize: 24)),
              ),
              title: Text(meal['name'], style: AppTheme.body),
              subtitle: Text(meal['meta'], style: AppTheme.bodyMuted),
              trailing: const Icon(
                Icons.more_vert,
                color: AppTheme.textMuted,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
}

/// ───────────────── AI TWEAK CHIP ─────────────────

class _TweakChip extends StatelessWidget {
  final String label;
  const _TweakChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

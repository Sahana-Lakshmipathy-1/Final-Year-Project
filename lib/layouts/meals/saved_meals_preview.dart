import 'package:flutter/material.dart';

class SavedMealsPreview extends StatelessWidget {
  const SavedMealsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1431);
    const card = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const muted = Color(0xFFB7C0E0);
    const edge = Color(0xFF2C315C);

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
          {
            'icon': '🍚',
            'name': 'Rajma Rice',
            'meta': 'Lunch • 560 kcal',
          },
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
      backgroundColor: bg,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C3A),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Your Plan ✨',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),

      /// BODY
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              /// AI TWEAKS
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: edge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Tweaks',
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          _TweakChip('🔥 Increase protein'),
                          _TweakChip('🥗 More vegetables'),
                          _TweakChip('⚖️ Lower calories'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// WEEKLY MEALS
              ...weekMeals.map((day) => _MealDayCard(day)).toList(),
            ],
          ),

          /// FLOATING ADD BUTTON
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: accent,
              onPressed: () {},
              child: const Icon(Icons.add, color: Color(0xFF1A1034)),
            ),
          ),
        ],
      ),

      /// BOTTOM ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF181C3A),
          border: Border(top: BorderSide(color: edge)),
        ),
        child: Row(
          children: [
            _bottomButton('🔀 Shuffle'),
            const SizedBox(width: 8),
            _bottomButton('💾 Save'),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '🍽 Start Plan',
                  style: TextStyle(
                    color: Color(0xFF1A1034),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton(String label) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF262B56),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {},
        child: Text(label),
      ),
    );
  }
}

/// ---------------- DAY CARD ----------------

class _MealDayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  const _MealDayCard(this.day);

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const muted = Color(0xFFB7C0E0);
    const edge = Color(0xFF2C315C);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: edge),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      day['day'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        day['type'],
                        style: const TextStyle(
                          color: Color(0xFF1A1034),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  day['calories'],
                  style: const TextStyle(color: muted),
                ),
              ],
            ),
          ),

          /// MEALS LIST
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
                  color: const Color(0xFF14183A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2C315C)),
                ),
                child: Text(
                  meal['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              title: Text(
                meal['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                meal['meta'],
                style: const TextStyle(color: muted),
              ),
              trailing: const Icon(Icons.more_vert, color: Colors.white54),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// ---------------- AI TWEAK CHIP ----------------

class _TweakChip extends StatelessWidget {
  final String label;
  const _TweakChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF262B56),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF343A6A)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB787FF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

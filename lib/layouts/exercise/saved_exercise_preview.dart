import 'package:flutter/material.dart';

class SavedExercisePreview extends StatefulWidget {
  const SavedExercisePreview({super.key});

  @override
  State<SavedExercisePreview> createState() => _SavedExercisePreviewState();
}

class _SavedExercisePreviewState extends State<SavedExercisePreview> {
  bool isLoading = false;
  String loadingText = 'Applying changes...';

  // Sample data
  final List<Map<String, dynamic>> weekPlan = [
    {
      'day': 'Monday',
      'type': 'Upper Body',
      'duration': '45 min',
      'exercises': [
        {'name': 'Push-ups', 'details': '3 sets × 12 reps', 'icon': '💪'},
        {'name': 'Dumbbell Rows', 'details': '3 sets × 10 reps', 'icon': '🏋️'},
        {'name': 'Shoulder Press', 'details': '3 sets × 12 reps', 'icon': '💪'},
        {'name': 'Bicep Curls', 'details': '3 sets × 15 reps', 'icon': '💪'},
      ],
    },
    {
      'day': 'Tuesday',
      'type': 'Lower Body',
      'duration': '40 min',
      'exercises': [
        {'name': 'Squats', 'details': '4 sets × 10 reps', 'icon': '🦵'},
        {'name': 'Lunges', 'details': '3 sets × 12 reps each', 'icon': '🚶'},
        {'name': 'Leg Press', 'details': '3 sets × 15 reps', 'icon': '🦵'},
        {'name': 'Calf Raises', 'details': '3 sets × 20 reps', 'icon': '🦵'},
      ],
    },
    {
      'day': 'Wednesday',
      'type': 'Rest',
      'isRest': true,
    },
    {
      'day': 'Thursday',
      'type': 'Core & Cardio',
      'duration': '35 min',
      'exercises': [
        {'name': 'Plank', 'details': '3 sets × 60 sec hold', 'icon': '🧘'},
        {
          'name': 'Mountain Climbers',
          'details': '3 sets × 20 reps',
          'icon': '⛰️',
        },
        {'name': 'Russian Twists', 'details': '3 sets × 30 reps', 'icon': '🔄'},
        {'name': 'Jump Rope', 'details': '3 sets × 2 min', 'icon': '🪢'},
      ],
    },
  ];

  // Actions
  void _showLoading(String text) {
    setState(() {
      isLoading = true;
      loadingText = text;
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() => isLoading = false);
    });
  }

  void _applyTweak(String type) {
    final messages = {
      'harder': 'Making it harder...',
      'bodyweight': 'Swapping to bodyweight...',
      'shorter': 'Shortening sessions...',
      'cardio': 'Adding cardio...',
      'stretch': 'Adding stretches...',
    };
    _showLoading(messages[type]!);
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0F1431);
    const Color card = Color(0xFF1E2248);
    const Color accent = Color(0xFFB787FF);
    const Color textColor = Color(0xFFE9ECFF);
    const Color muted = Color(0xFFB7C0E0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C3A),
        title: const Text(
          'Your Plan ✨',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showLoading('Opening menu...'),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // Refinement Chips
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2348).withOpacity(0.9),
                  border: Border.all(color: accent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Tweaks',
                      style: TextStyle(
                        fontSize: 12,
                        color: muted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(
                            '🔥 Make it harder',
                            () => _applyTweak('harder'),
                          ),
                          _buildChip(
                            '🏃 Swap to bodyweight',
                            () => _applyTweak('bodyweight'),
                          ),
                          _buildChip(
                            '⏱️ Shorter sessions',
                            () => _applyTweak('shorter'),
                          ),
                          _buildChip(
                            '❤️ Add more cardio',
                            () => _applyTweak('cardio'),
                          ),
                          _buildChip(
                            '🧘 More stretching',
                            () => _applyTweak('stretch'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Weekly Plan
              ...weekPlan
                  .map(
                    (day) => _buildDayCard(day, card, accent, textColor, muted),
                  )
                  .toList(),
            ],
          ),

          // Bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF181C3A).withOpacity(0.98),
                border: const Border(top: BorderSide(color: Color(0xFF2C315C))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      '🔀 Shuffle',
                      () => _showLoading('Shuffling plan...'),
                      bgColor: const Color(0xFF262B56),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton(
                      '💾 Save',
                      () => _showLoading('Saving plan...'),
                      bgColor: const Color(0xFF262B56),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildButton(
                      '🚀 Start Workout',
                      () => _showLoading('Starting workout...'),
                      bgColor: accent,
                      textColor: const Color(0xFF1A1034),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: accent,
              onPressed: () => _showLoading('Quick Actions...'),
              child: const Icon(Icons.add, color: Color(0xFF1A1034), size: 30),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: bg.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loadingText,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x1AB787FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x4DB787FF)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB787FF),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(
    Map<String, dynamic> day,
    Color card,
    Color accent,
    Color textColor,
    Color muted,
  ) {
    final isRest = day['isRest'] == true;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C315C)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isRest ? Colors.green.withOpacity(0.2) : accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isRest ? 'Rest' : day['type'],
                        style: TextStyle(
                          color: isRest
                              ? Colors.greenAccent
                              : const Color(0xFF1A1034),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isRest)
                  Text(
                    day['duration'],
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (isRest)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text('😌', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Recovery Day',
                    style: TextStyle(
                      color: Colors.greenAccent.shade200,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Take it easy and let your muscles recover',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(day['exercises'].length, (i) {
                final ex = day['exercises'][i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2248),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2C315C)),
                    ),
                    child: Text(
                      ex['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    ex['name'],
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    ex['details'],
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    onPressed: () => _showLoading('Editing ${ex['name']}...'),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    VoidCallback onPressed, {
    required Color bgColor,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    );
  }
}

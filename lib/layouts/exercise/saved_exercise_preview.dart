import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class SavedExercisePreview extends StatefulWidget {
  const SavedExercisePreview({super.key});

  @override
  State<SavedExercisePreview> createState() => _SavedExercisePreviewState();
}

class _SavedExercisePreviewState extends State<SavedExercisePreview> {
  bool isLoading = false;
  String loadingText = 'Applying changes...';

  /// SAMPLE DATA
  final List<Map<String, dynamic>> weekPlan = [
    {
      'day': 'Monday',
      'type': 'Upper Body',
      'duration': '45 min',
      'exercises': [
        {'name': 'Push-ups', 'details': '3 × 12', 'icon': '💪'},
        {'name': 'Dumbbell Rows', 'details': '3 × 10', 'icon': '🏋️'},
      ],
    },
    {
      'day': 'Tuesday',
      'type': 'Lower Body',
      'duration': '40 min',
      'exercises': [
        {'name': 'Squats', 'details': '4 × 10', 'icon': '🦵'},
        {'name': 'Lunges', 'details': '3 × 12', 'icon': '🚶'},
      ],
    },
    {
      'day': 'Wednesday',
      'isRest': true,
    },
  ];

  void _showLoading(String text) {
    setState(() {
      isLoading = true;
      loadingText = text;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Your Weekly Plan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showLoading("Opening options…"),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _aiTweaks(),
              ...weekPlan.map(_dayCard),
            ],
          ),

          /// BOTTOM ACTION BAR
          _bottomBar(),

          /// LOADING OVERLAY
          if (isLoading) _loadingOverlay(),
        ],
      ),
    );
  }

  /// ───────────────── AI TWEAKS ─────────────────

  Widget _aiTweaks() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AI Suggestions", style: AppTheme.h2),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tweakChip("🔥 Harder", "Making it harder…"),
                _tweakChip("⏱ Shorter", "Shortening sessions…"),
                _tweakChip("❤️ Cardio", "Adding cardio…"),
                _tweakChip("🧘 Stretch", "Adding stretches…"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tweakChip(String label, String action) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _showLoading(action),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// ───────────────── DAY CARD ─────────────────

  Widget _dayCard(Map<String, dynamic> day) {
    final bool isRest = day['isRest'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(day['day'], style: AppTheme.h2),
                    const SizedBox(width: 8),
                    _tag(
                      isRest ? "Rest" : day['type'],
                      isRest ? AppTheme.success : AppTheme.primary,
                    ),
                  ],
                ),
                if (!isRest) Text(day['duration'], style: AppTheme.caption),
              ],
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(14),
            child: isRest
                ? Column(
                    children: [
                      const Text("😌", style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 6),
                      Text("Recovery Day", style: AppTheme.h2),
                      const SizedBox(height: 4),
                      Text(
                        "Let your body recover and reset",
                        style: AppTheme.bodyMuted,
                      ),
                    ],
                  )
                : Column(
                    children: List.generate(day['exercises'].length, (i) {
                      final ex = day['exercises'][i];
                      return _exerciseRow(ex);
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseRow(Map<String, dynamic> ex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cardBgAlt,
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Text(ex['icon'], style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex['name'], style: AppTheme.body),
                Text(ex['details'], style: AppTheme.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
            onPressed: () => _showLoading("Editing ${ex['name']}…"),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// ───────────────── BOTTOM BAR ─────────────────

  Widget _bottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: AppTheme.borderSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: AppTheme.ghostButton,
                onPressed: () => _showLoading("Shuffling plan…"),
                child: const Text("Shuffle"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () => _showLoading("Starting workout…"),
                child: const Text("Start Workout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── LOADING ─────────────────

  Widget _loadingOverlay() {
    return Container(
      color: AppTheme.bg.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(loadingText, style: AppTheme.body),
          ],
        ),
      ),
    );
  }
}

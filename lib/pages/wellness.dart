import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

import 'package:lumora/layouts/wellness/sleep_tracker.dart';
import 'package:lumora/layouts/wellness/mood_analysis.dart';
import 'package:lumora/layouts/wellness/wellness_bot.dart';
import 'package:lumora/layouts/wellness/wellness_action_card.dart';

import 'package:lumora/layouts/wellness/meditation_library_page.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

/* -------------------------------------------------------------------------- */
/*                                  MODELS                                    */
/* -------------------------------------------------------------------------- */

class MoodOption {
  final IconData icon;
  final String label;
  final Color color;

  const MoodOption({
    required this.icon,
    required this.label,
    required this.color,
  });
}

const List<MoodOption> moodOptions = [
  MoodOption(icon: LucideIcons.angry, label: "Angry", color: Colors.red),
  MoodOption(icon: LucideIcons.frown, label: "Sad", color: Colors.orange),
  MoodOption(icon: LucideIcons.meh, label: "Neutral", color: Colors.yellow),
  MoodOption(icon: LucideIcons.smile, label: "Happy", color: Colors.green),
  MoodOption(
    icon: LucideIcons.laugh,
    label: "Energized",
    color: Color(0xFF1B5E20),
  ),
];

/* -------------------------------------------------------------------------- */
/*                                  PAGE                                      */
/* -------------------------------------------------------------------------- */

class _WellnessPageState extends State<WellnessPage> {
  int _selectedMoodIndex = 3;

  void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Wellness", style: AppTheme.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MoodCheckInCard(
              selectedIndex: _selectedMoodIndex,
              onSelect: (i) => setState(() => _selectedMoodIndex = i),
            ),

            const SizedBox(height: 28),

            WellnessActionCard(
              title: "Mood insights",
              subtitle: "Understand your emotional patterns",
              cta: "View insights",
              icon: LucideIcons.lineChart,
              onTap: () => _go(context, const MoodInsightsPage()),
            ),

            WellnessActionCard(
              title: "Sleep tracker",
              subtitle: "Build better rest habits",
              cta: "Log sleep",
              icon: LucideIcons.moon,
              onTap: () => _go(context, const SleepTrackerPage()),
            ),

            WellnessActionCard(
              title: "Talk it out",
              subtitle: "Chat with your wellness assistant",
              cta: "Start conversation",
              icon: LucideIcons.messageCircle,
              onTap: () => _go(context, const WellnessChatPage()),
            ),

            const SizedBox(height: 28),

            /// ------------------ MEDITATION CTA ------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _go(context, const MeditationLibraryPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardBgAlt,
                  foregroundColor: AppTheme.textWhite,
                  elevation: 8,
                  shadowColor: AppTheme.primary.withOpacity(0.25),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
                    side: BorderSide(
                      color: AppTheme.primary.withOpacity(0.4),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.leaf,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Try a short meditation",
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                          MOOD CHECK-IN CARD                                 */
/* -------------------------------------------------------------------------- */

class _MoodCheckInCard extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _MoodCheckInCard({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How are you feeling right now?", style: AppTheme.h3),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(moodOptions.length, (index) {
              final mood = moodOptions[index];
              final isActive = selectedIndex == index;

              return Tooltip(
                message: mood.label,
                child: GestureDetector(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isActive
                          ? mood.color.withOpacity(0.15)
                          : AppTheme.cardBgAlt,
                      borderRadius: AppTheme.radiusMedium,
                      border: Border.all(
                        color: isActive ? mood.color : AppTheme.borderSoft,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: mood.color.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      mood.icon,
                      size: 24,
                      color: isActive ? mood.color : AppTheme.textMuted,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

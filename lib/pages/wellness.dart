import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/wellness/sleep_tracker.dart';
import 'package:lumora/layouts/wellness/mood_analysis.dart';
import 'package:lumora/layouts/wellness/wellness_bot.dart';
import 'package:lumora/layouts/wellness/wellness_action_card.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  int selectedMood = 4;
  final moods = ["😩", "😟", "😐", "😊", "😁"];

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
            /// ------------------------------------------------------------
            /// HERO – MOOD CHECK-IN
            /// ------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.elevatedCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("How are you feeling right now?", style: AppTheme.h3),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(moods.length, (i) {
                      final active = selectedMood == i;
                      return GestureDetector(
                        onTap: () => setState(() => selectedMood = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.primary.withOpacity(.2)
                                : AppTheme.cardBgAlt,
                            borderRadius: AppTheme.radiusMedium,
                            border: Border.all(
                              color: active
                                  ? AppTheme.primary
                                  : AppTheme.borderSoft,
                              width: active ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            moods[i],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ------------------------------------------------------------
            /// MOOD INSIGHTS
            /// ------------------------------------------------------------
            WellnessActionCard(
              title: "Mood insights",
              subtitle: "Understand your emotional patterns",
              cta: "Analyze with AI",
              icon: Icons.insights,
              onTap: () => _go(const MoodInsightsPage()),
            ),

            /// ------------------------------------------------------------
            /// SLEEP
            /// ------------------------------------------------------------
            WellnessActionCard(
              title: "Sleep tracker",
              subtitle: "Build better rest habits",
              cta: "Log sleep",
              icon: Icons.bedtime_rounded,
              onTap: () => _go(const SleepTrackerPage()),
            ),

            /// ------------------------------------------------------------
            /// SUPPORT
            /// ------------------------------------------------------------
            WellnessActionCard(
              title: "Talk it out",
              subtitle: "Chat with your wellness assistant",
              cta: "Start conversation",
              icon: Icons.chat_bubble_outline,
              onTap: () => _go(const WellnessChatPage()),
            ),

            const SizedBox(height: 24),

            /// ------------------------------------------------------------
            /// SOFT CTA
            /// ------------------------------------------------------------
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Looking for meditation?",
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

// --- SERVICE IMPORT ---
import 'package:lumora/services/api_service.dart';

// --- YOUR EXISTING PAGE IMPORTS ---
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
/* MODELS                                   */
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
/* PAGE                                    */
/* -------------------------------------------------------------------------- */

class _WellnessPageState extends State<WellnessPage> {
  int _selectedMoodIndex = 3;
  bool _isLogging = false;
  final ApiService _api = ApiService();

  // --- NEW: Handle the API Call with Dialog ---
  Future<void> _handleCheckIn() async {
    final TextEditingController noteController = TextEditingController();

    // 1. Show Dialog to get a Note
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text("Add a note?", style: AppTheme.h3),
        content: TextField(
          controller: noteController,
          style: AppTheme.body,
          decoration: InputDecoration(
            hintText: "Why do you feel this way?",
            hintStyle: AppTheme.bodySmall, // Ensure this exists in AppTheme
            filled: true,
            fillColor: AppTheme.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Log Mood",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) return;

    // 2. Call API
    setState(() => _isLogging = true);

    try {
      final mood = moodOptions[_selectedMoodIndex];

      // REPLACE "user@example.com" with actual user email from Auth provider later
      print("Attempting to log mood for user@example.com...");

      await _api.logMood(
        email: "user@example.com",
        mood: mood.label,
        score: _selectedMoodIndex + 1, // 1 to 5 scale
        note: noteController.text,
      );

      print("✅ API Success");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Mood logged successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print("❌ API Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to log mood: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

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
              onCheckInTap: _handleCheckIn,
              isLoading: _isLogging,
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
/* MOOD CHECK-IN CARD                             */
/* -------------------------------------------------------------------------- */

class _MoodCheckInCard extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheckInTap; // New Callback
  final bool isLoading; // New Loading State

  const _MoodCheckInCard({
    required this.selectedIndex,
    required this.onSelect,
    required this.onCheckInTap,
    required this.isLoading,
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

          // Mood Icons Row
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
                    width: 50, // Slightly reduced to ensure fit
                    height: 50,
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

          const SizedBox(height: 20),

          // --- NEW: Check In Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCheckInTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Log Today's Mood",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

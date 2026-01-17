import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/wellness/meditation_player_screen.dart';

class MeditationLibraryPage extends StatelessWidget {
  const MeditationLibraryPage({super.key});

  void _openSession(BuildContext context, _MeditationSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeditationPlayerPage(title: session.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Meditation", style: AppTheme.h2),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            "Find a moment of calm.",
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: 24),

          ...sessions.map(
            (session) => _MeditationCard(
              session: session,
              onTap: () => _openSession(context, session),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  DATA                                      */
/* -------------------------------------------------------------------------- */

class _MeditationSession {
  final String title;
  final String type;
  final String duration;
  final String description;
  final IconData icon;

  const _MeditationSession({
    required this.title,
    required this.type,
    required this.duration,
    required this.description,
    required this.icon,
  });
}

const List<_MeditationSession> _sessions = [
  _MeditationSession(
    title: "Morning Gratitude",
    type: "Guided",
    duration: "5 min",
    description:
        "Start your day with a positive mindset by focusing on gratitude.",
    icon: LucideIcons.sunrise,
  ),
  _MeditationSession(
    title: "Box Breathing",
    type: "Breathing",
    duration: "3 min",
    description: "A simple breathing technique to calm your nervous system.",
    icon: LucideIcons.wind,
  ),
  _MeditationSession(
    title: "Rainforest Ambience",
    type: "Soundscape",
    duration: "15 min",
    description: "Immerse yourself in calming rainforest sounds.",
    icon: LucideIcons.cloudRain,
  ),
  _MeditationSession(
    title: "Stress Relief",
    type: "Guided",
    duration: "10 min",
    description: "Release tension and relax your body and mind.",
    icon: LucideIcons.heartPulse,
  ),
  _MeditationSession(
    title: "Mindful Breathing",
    type: "Breathing",
    duration: "5 min",
    description: "Anchor yourself in the present moment through breath.",
    icon: LucideIcons.activity,
  ),
];

/* -------------------------------------------------------------------------- */
/*                               SESSION CARD                                 */
/* -------------------------------------------------------------------------- */

class _MeditationCard extends StatelessWidget {
  final _MeditationSession session;
  final VoidCallback onTap;

  const _MeditationCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.elevatedCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(.15),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Icon(session.icon, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(session.title, style: AppTheme.h3),
                  ),
                  Icon(
                    LucideIcons.playCircle,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// META
              Row(
                children: [
                  _MetaChip(session.type),
                  const SizedBox(width: 8),
                  _MetaChip(session.duration),
                ],
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              Text(
                session.description,
                style: AppTheme.bodyMuted.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                 META CHIP                                  */
/* -------------------------------------------------------------------------- */

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Text(label, style: AppTheme.caption),
    );
  }
}

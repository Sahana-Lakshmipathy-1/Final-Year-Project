import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class MoodInsightsPage extends StatelessWidget {
  const MoodInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.primary),
        title: Text(
          "AI Mood Insights",
          style: AppTheme.h2,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.cardBgAlt, AppTheme.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InsightCard(
                  title: "🧠 Overall Mood Trend",
                  content:
                      "Your mood has remained mostly stable and positive. Small dips align with low-sleep days.",
                  highlight:
                      "Mood Stability Score: 8.3 / 10  •  ↑ 0.7 vs last week",
                  footer: "😐 😊 😁 😊 😐 😴 😊",
                ),

                _InsightCard(
                  title: "🌙 Sleep Impact",
                  content:
                      "You average 6h 20m of sleep. Days above 7h consistently show better focus and morning mood.",
                  tip: "Try maintaining a fixed bedtime around 11:00 PM.",
                ),

                _InsightCard(
                  title: "🏋️ Exercise & Energy",
                  content:
                      "Workout consistency strongly boosts energy levels. Mid-week activity peaks help maintain momentum.",
                  tag: "Motivation Momentum: High",
                ),

                _InsightCard(
                  title: "🥗 Nutrition Influence",
                  content:
                      "Balanced meals and hydration improve post-workout mood. Skipping breakfast lowers mid-day energy.",
                  tip: "Include protein + complex carbs in breakfast.",
                ),

                _InsightCard(
                  title: "💫 AI Reflection",
                  content:
                      "You’re doing well maintaining balance. Improving sleep regularity will amplify both physical and mental gains.",
                ),

                const SizedBox(height: 28),

                _ActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               INSIGHT CARD                                 */
/* -------------------------------------------------------------------------- */

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final String? highlight;
  final String? footer;
  final String? tip;
  final String? tag;

  const _InsightCard({
    required this.title,
    required this.content,
    this.highlight,
    this.footer,
    this.tip,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.h2.copyWith(fontSize: 16)),

          const SizedBox(height: 8),

          Text(
            content,
            style: AppTheme.bodyMuted.copyWith(height: 1.5),
          ),

          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(footer!, style: const TextStyle(fontSize: 22)),
          ],

          if (highlight != null) ...[
            const SizedBox(height: 12),
            _HighlightBox(text: highlight!),
          ],

          if (tag != null) ...[
            const SizedBox(height: 12),
            _Tag(label: tag!),
          ],

          if (tip != null) ...[
            const SizedBox(height: 12),
            _TipBox(text: tip!),
          ],
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                SUB BLOCKS                                  */
/* -------------------------------------------------------------------------- */

class _HighlightBox extends StatelessWidget {
  final String text;
  const _HighlightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: AppTheme.body.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String text;
  const _TipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Text(
        "💡 $text",
        style: AppTheme.caption.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.warning,
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                ACTION BAR                                  */
/* -------------------------------------------------------------------------- */

class _ActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          _ActionButton(
            label: "Save Insight",
            color: AppTheme.success,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Insight saved to journal")),
              );
            },
          ),
          _ActionButton(
            label: "Re-analyze",
            color: AppTheme.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Re-analyzing mood data")),
              );
            },
          ),
          _ActionButton(
            label: "Ask AI",
            color: AppTheme.cardBgAlt,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening AI wellness chat")),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusMedium,
          ),
          elevation: 6,
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.body.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

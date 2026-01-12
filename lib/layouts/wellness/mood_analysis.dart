import 'package:flutter/material.dart';

class MoodInsightsPage extends StatelessWidget {
  const MoodInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg1 = Color(0xFF0F1431);
    const bg2 = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const accent2 = Color(0xFF2FE0C7);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);

    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "AI Mood Insights 💫",
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bg2, bg1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightCard(
                  title: "🧠 Overall Mood Trend",
                  content:
                      "Your mood has been mostly uplifting and stable, with small dips on low-sleep days.",
                  highlight:
                      "🌤️ Mood Stability Score: 8.3/10 (↑ 0.7 from last week)",
                  emoji: "😐 😊 😁 😊 😐 😴 😊",
                ),
                _buildInsightCard(
                  title: "🌙 Sleep Impact Insight",
                  content:
                      "Your average sleep duration is 6h 20m. Days with more than 7 hours of rest show noticeably better morning moods and focus.",
                  tip:
                      "💡 Try maintaining a consistent bedtime around 11:00 PM.",
                ),
                _buildInsightCard(
                  title: "🏋️‍♀️ Exercise Connection",
                  content:
                      "Exercise frequency positively correlates with your energy and mood. You’re most active mid-week — maintaining that rhythm boosts consistency.",
                  tag: "🔥 Motivation Momentum: High",
                ),
                _buildInsightCard(
                  title: "🥗 Diet Influence",
                  content:
                      "Higher protein intake and proper hydration seem to enhance post-workout moods. Skipping breakfast correlates with lower mid-day energy.",
                  tip:
                      "🍳 Try balanced breakfasts with complex carbs and lean proteins.",
                ),
                _buildInsightCard(
                  title: "💫 AI Reflection Summary",
                  content:
                      "You’re doing great at maintaining balance. Focus on improving sleep regularity, and your body and mind will thank you. Remember, consistency beats perfection. 💜",
                ),

                const SizedBox(height: 28),
                _buildActionButtons(context, accent, accent2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String content,
    String? highlight,
    String? emoji,
    String? tip,
    String? tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(230, 35, 39, 95),
            Color.fromARGB(230, 28, 31, 70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFF2C315C)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFFD8DCFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFB7C0E0),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (emoji != null) ...[
            const SizedBox(height: 8),
            Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ],
          if (highlight != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF202657),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF313873)),
              ),
              child: Text(
                highlight,
                style: const TextStyle(
                  color: Color(0xFFB787FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          if (tag != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF262B56),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3A3F72)),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Color(0xFFFFA06A),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          if (tip != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14183A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2B2F58)),
              ),
              child: Text(
                tip,
                style: const TextStyle(
                  color: Color(0xFFE9ECFF),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Color accent,
    Color accent2,
  ) {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          _buildActionButton(
            label: "📝 Save Insight",
            color: accent2,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Insight saved to journal!")),
              );
            },
          ),
          _buildActionButton(
            label: "🔁 Re-analyze",
            color: accent,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Re-analyzing data...")),
              );
            },
          ),
          _buildActionButton(
            label: "💬 Ask AI More",
            color: const Color(0xFF8B6BFF),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Launching AI wellness chat...")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 8,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1A1034),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

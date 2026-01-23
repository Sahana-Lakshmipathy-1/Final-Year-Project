import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

class MoodInsightsPage extends StatefulWidget {
  const MoodInsightsPage({super.key});

  @override
  State<MoodInsightsPage> createState() => _MoodInsightsPageState();
}

class _MoodInsightsPageState extends State<MoodInsightsPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String _statusMessage = "Analyzing your day...";
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  // --- 🚀 THE POLLING ENGINE ---
  Future<void> _startAnalysis() async {
    final String? journalId = UserSession.lastJournalId;

    if (journalId == null) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            "No recent log found to analyze. Please log your day first.";
      });
      return;
    }

    try {
      // 1. Request AI Generation
      final initResponse = await _api.generateWellnessReflection(journalId);
      final String reflectionId = initResponse['reflection_id'];

      // 2. Poll for Completion
      bool isComplete = false;
      int attempts = 0;
      const int maxAttempts = 15; // Max 75 seconds

      while (!isComplete && attempts < maxAttempts) {
        attempts++;
        setState(() => _statusMessage = "AI is reflecting... ($attempts)");

        await Future.delayed(const Duration(seconds: 5));

        final statusResponse = await _api.checkReflectionStatus(reflectionId);
        final String status = statusResponse['status'] ?? "PROCESSING";

        if (status == "COMPLETED") {
          setState(() {
            _data = statusResponse['data'];
            _isLoading = false;
          });
          isComplete = true;
        } else if (status == "FAILED") {
          throw Exception("AI Analysis encountered an error.");
        }
      }

      if (!isComplete) throw Exception("Analysis timed out. Please try again.");
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        title: Text("Daily AI Insights", style: AppTheme.h2),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.cardBgAlt, AppTheme.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? _buildLoader()
            : (_data == null ? _buildError() : _buildContent()),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 20),
          Text(_statusMessage, style: AppTheme.bodyMuted),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: AppTheme.body,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. AI GENERATED SUMMARY
            Text("Today's Summary", style: AppTheme.sectionTitle),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.elevatedCard.copyWith(
                color: AppTheme.primary.withOpacity(0.05),
              ),
              child: Text(
                _data!['ai_generated_summary'] ?? "No summary available.",
                style: AppTheme.body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// 2. COPING STRATEGIES (Tags)
            if (_data!['coping_strategies_used'] != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_data!['coping_strategies_used'] as List)
                    .map((s) => _Tag(label: s.toString().replaceAll('_', ' ')))
                    .toList(),
              ),
            const SizedBox(height: 24),

            /// 3. MAIN INSIGHT CARDS
            _InsightCard(
              title: "Mood Trend",
              content: _data!['mood_trend']['summary'],
              highlight: "Stability Score: ${_data!['mood_trend']['score']}/10",
            ),

            _InsightCard(
              title: "Sleep Impact",
              content: _data!['sleep_impact']['insight'],
              tip: _data!['sleep_impact']['tip'],
            ),

            _InsightCard(
              title: "Exercise & Energy",
              content: _data!['exercise_impact']['insight'],
              tag: "Momentum: ${_data!['exercise_impact']['momentum_score']}",
            ),

            _InsightCard(
              title: "Nutrition Influence",
              content: _data!['nutrition_impact']['insight'],
              tip: _data!['nutrition_impact']['tip'],
            ),

            /// 4. ACTION PLAN FOR TOMORROW
            _SectionHeader(title: "Plan for tomorrow"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: AppTheme.radiusSmall,
                border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    _data!['action_plan_next_day'] ?? "Keep up the good work!",
                    style: AppTheme.body,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 5. LESSONS LEARNED
            _InsightCard(
              title: "Lessons Learned",
              content:
                  _data!['lessons_learned'] ??
                  "Every day is a step toward growth.",
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* REUSABLE COMPONENTS                                                         */
/* -------------------------------------------------------------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final String? highlight;
  final String? tip;
  final String? tag;

  const _InsightCard({
    required this.title,
    required this.content,
    this.highlight,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.h3.copyWith(
                  fontSize: 15,
                  color: AppTheme.primary,
                ),
              ),
              if (tag != null) _Tag(label: tag!, color: AppTheme.warning),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTheme.bodyMuted.copyWith(
              height: 1.5,
              color: Colors.white70,
            ),
          ),
          if (highlight != null) ...[
            const SizedBox(height: 14),
            _HighlightBox(text: highlight!),
          ],
          if (tip != null) ...[
            const SizedBox(height: 14),
            _TipBox(text: tip!),
          ],
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  final String text;
  const _HighlightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
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
    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Tip: $text",
            style: AppTheme.caption.copyWith(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  const _Tag({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color ?? AppTheme.primary,
        ),
      ),
    );
  }
}

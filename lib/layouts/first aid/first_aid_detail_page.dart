import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

class FirstAidDetailPage extends StatefulWidget {
  final String categoryId;

  const FirstAidDetailPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<FirstAidDetailPage> createState() => _FirstAidDetailPageState();
}

class _FirstAidDetailPageState extends State<FirstAidDetailPage> {
  Map<String, dynamic>? _categoryData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final jsonString = await rootBundle.loadString(
      "assets/data/first_aid_data.json",
    );
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    final categories = (jsonData["categories"] as List<dynamic>);
    final category = categories.firstWhere(
      (c) => c["id"] == widget.categoryId,
      orElse: () => null,
    );

    setState(() {
      _categoryData = category;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoryData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Not Found"),
        ),
        body: Center(child: const Text("Category not found.")),
      );
    }

    final steps = List<Map<String, dynamic>>.from(_categoryData!["steps"]);
    final warnings = List<String>.from(_categoryData!["warnings"] ?? []);
    final seekHelp = List<String>.from(_categoryData!["seek_help_if"] ?? []);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_categoryData!["title"], style: AppTheme.h2),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            /// ------------------------- STEPS -----------------------------
            Text(
              "What to do",
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: 12),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              return _StepTile(
                number: index + 1,
                title: step["title"],
                description: step["description"],
              );
            }),

            const SizedBox(height: 24),

            /// ---------------------- WARNINGS ----------------------------
            if (warnings.isNotEmpty) ...[
              Text(
                "Do NOT do this",
                style: AppTheme.sectionTitle,
              ),
              const SizedBox(height: 8),
              ...warnings.map((w) => _BulletText(w)),
              const SizedBox(height: 24),
            ],

            /// --------------------- SEEK HELP ----------------------------
            if (seekHelp.isNotEmpty) ...[
              Text(
                "Seek medical help if:",
                style: AppTheme.sectionTitle,
              ),
              const SizedBox(height: 8),
              ...seekHelp.map((w) => _BulletText(w)),
              const SizedBox(height: 24),
            ],

            /// ---------------- EMERGENCY CTA BUTTON ---------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Call emergency contact
                },
                icon: const Icon(LucideIcons.phoneCall),
                label: const Text("Call Emergency Contact"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
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

/* -------------------------------------------------------------------------- */
/*                                STEP TILE                                   */
/* -------------------------------------------------------------------------- */

class _StepTile extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number.",
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTheme.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               BULLET TEXT                                  */
/* -------------------------------------------------------------------------- */

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("•", style: AppTheme.body),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTheme.bodyMuted)),
        ],
      ),
    );
  }
}

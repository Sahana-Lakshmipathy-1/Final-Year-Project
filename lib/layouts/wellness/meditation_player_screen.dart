import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

class MeditationPlayerPage extends StatelessWidget {
  final String title;

  const MeditationPlayerPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Container(
            width: double.infinity,
            decoration: AppTheme.elevatedCard,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTheme.h2),
                const SizedBox(height: 12),

                Text(
                  "Immerse yourself in the experience.\nLet everything else fade.",
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMuted,
                ),

                const SizedBox(height: 32),

                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.headphones,
                    size: 44,
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Audio player is playing",
                  style: AppTheme.caption,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: AppTheme.primaryButton,
                    onPressed: () => Navigator.pop(context),
                    child: const Text("End session"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

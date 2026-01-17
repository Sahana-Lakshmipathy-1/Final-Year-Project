import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

import 'package:lumora/layouts/first aid/first_aid_category_card.dart';
import 'package:lumora/layouts/first aid/first_aid_chatbot.dart';
import 'package:lumora/layouts/first aid/first_aid_detail_page.dart';

class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirstAidChatPage()),
    );
  }

  void _openCategory(BuildContext context, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirstAidDetailPage(categoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("First Aid", style: AppTheme.h2),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            /// ------------------------------------------------------------------
            /// DISCLAIMER
            /// ------------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBgAlt,
                borderRadius: AppTheme.radiusMedium,
                border: Border.all(color: AppTheme.borderSoft),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This guide provides basic first aid information and is not a replacement for professional medical care.",
                      style: AppTheme.caption.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ------------------------------------------------------------------
            /// PAGE TITLE
            /// ------------------------------------------------------------------
            Text(
              "What do you need help with?",
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: 6),
            Text(
              "Select a category to get step-by-step guidance.",
              style: AppTheme.caption,
            ),

            const SizedBox(height: 20),

            /// ------------------------------------------------------------------
            /// CATEGORY GRID
            /// ------------------------------------------------------------------
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                FirstAidCategoryCard(
                  icon: LucideIcons.activity,
                  title: "Sprains & Fractures",
                  subtitle: "Joint & muscle injuries",
                  onTap: () => _openCategory(context, "sprains_fractures"),
                ),
                FirstAidCategoryCard(
                  icon: LucideIcons.scissors,
                  title: "Cuts & Bleeding",
                  subtitle: "Wounds & bleeding control",
                  onTap: () => _openCategory(context, "cuts_bleeding"),
                ),
                FirstAidCategoryCard(
                  icon: LucideIcons.flame,
                  title: "Burns & Scalds",
                  subtitle: "Heat & chemical burns",
                  onTap: () => _openCategory(context, "burns_scalds"),
                ),
                FirstAidCategoryCard(
                  icon: LucideIcons.alertTriangle,
                  title: "Choking",
                  subtitle: "Breathing emergencies",
                  onTap: () => _openCategory(context, "choking"),
                ),
                FirstAidCategoryCard(
                  icon: LucideIcons.bug,
                  title: "Bites & Allergies",
                  subtitle: "Stings, bites & reactions",
                  onTap: () => _openCategory(context, "bites_allergies"),
                ),
                FirstAidCategoryCard(
                  icon: LucideIcons.flaskConical,
                  title: "Poisoning",
                  subtitle: "Heat, poison & exposure",
                  onTap: () => _openCategory(context, "poisoning"),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// ------------------------------------------------------------------
            /// FIRST AID CHAT BOT CTA
            /// ------------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.elevatedCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(.15),
                          borderRadius: AppTheme.radiusSmall,
                        ),
                        child: Icon(
                          LucideIcons.messageCircle,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Get Help With Any Situation",
                          style: AppTheme.h3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Chat with our First Aid Assistant for guided help based on your situation.",
                    style: AppTheme.bodyMuted,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openChat(context),
                      style: AppTheme.primaryButton,
                      child: const Text("Start First Aid Chat"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// ------------------------------------------------------------------
            /// EMERGENCY CTA
            /// ------------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: AppTheme.radiusMedium,
                border: Border.all(color: AppTheme.error.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency situation?",
                    style: AppTheme.h3.copyWith(color: AppTheme.error),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "If the person is unconscious, not breathing, bleeding heavily, or in severe pain, seek immediate help.",
                    style: AppTheme.caption,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Call emergency contact / relative
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
          ],
        ),
      ),
    );
  }
}

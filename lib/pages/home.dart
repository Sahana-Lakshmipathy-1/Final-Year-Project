import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/user_session.dart'; // ✅ Import UserSession

import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/tracker.dart';
import 'package:lumora/pages/wellness.dart';
import "package:lumora/pages/first_aid.dart";

import 'package:lumora/layouts/home/today_focus.dart';
import 'package:lumora/layouts/home/progress.dart';
import 'package:lumora/layouts/home/smart_action.dart';
import 'package:lumora/layouts/home/explore_icon.dart';
import 'package:lumora/layouts/home/today_meal.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/pages/login.dart';

class HomeScreen extends StatelessWidget {
  // ✅ CLEAN: No constructor arguments needed anymore
  const HomeScreen({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --------------------------------------------------------
              /// GREETING HEADER (Uses UserSession)
              /// --------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Greeting text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Good evening,", style: AppTheme.bodyMuted),
                      Text(
                        UserSession.name ?? "User", // ✅ Global Access
                        style: AppTheme.h1,
                      ),
                    ],
                  ),

                  // Right side: User Avatar
                  // Container(
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     color: AppTheme.cardBg,
                  //     shape: BoxShape.circle,
                  //     border: Border.all(color: AppTheme.borderSoft),
                  //   ),
                  //   child: const Icon(Icons.person, color: Colors.white),
                  // ),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "logout",
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == "logout") {
                        // 🔹 Step 1 — Confirmation Bottom Sheet (better UX than alert)
                        bool? confirm = await showModalBottomSheet<bool>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Log out of Lumora?",
                                  style: AppTheme.h2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "You can log back in anytime.",
                                  style: AppTheme.bodyMuted,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.danger,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Logout"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );

                        if (confirm != true) return;

                        // 🔹 Step 2 — Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          final response = await ApiService().logOut(UserSession.email);

                          Navigator.pop(context); // close loader

                          if (response["message"] == "Logged out successfully") {
                            // 🔹 Step 3 — Clear session
                            UserSession.clear();

                            // 🔹 Step 4 — Success Snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Logged out successfully 👋"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // 🔹 Step 5 — Smooth redirect to login
                            await Future.delayed(const Duration(milliseconds: 600));
                            Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );

                          }
                        } catch (e) {
                          Navigator.pop(context); // close loader
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Logout failed. Try again."),
                              backgroundColor: AppTheme.danger,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSoft),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),


                ],
              ),

              const SizedBox(height: 6),
              Text("Let’s take care of you today.", style: AppTheme.bodyMuted),

              const SizedBox(height: 24),

              /// TODAY FOCUS
              TodayFocusCard(
                title: "Today’s Workout",
                subtitle: "Upper body • 45 min",
                cta: "Start now",
                onTap: () => _go(context, const TrackerScreen()),
              ),

              const SizedBox(height: 16),

              TodayMealCard(
                title: "Today’s Meals",
                subtitle: "3 meals planned • 1,850 kcal",
                cta: "View meal plan",
                onTap: () => _go(context, const TrackerScreen()),
              ),

              const SizedBox(height: 20),

              /// PROGRESS
              const ProgressStrip(),

              const SizedBox(height: 28),

              /// SMART ACTIONS
              Text("Quick actions", style: AppTheme.sectionTitle),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: SmartActionCard(
                      icon: Icons.self_improvement,
                      title: "Mood check-in",
                      subtitle: "How are you feeling?",
                      onTap: () => _go(context, const WellnessPage()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SmartActionCard(
                      icon: Icons.insights,
                      title: "First Aid",
                      subtitle: "Talk to our first bot",
                      onTap: () => _go(context, const FirstAidPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// EXPLORE
              Text("Explore", style: AppTheme.sectionTitle),
              const SizedBox(height: 14),

              Row(
                children: [
                  ExploreIcon(
                    icon: Icons.calendar_month,
                    label: "Plans",
                    onTap: () => _go(context, const PlansScreen()),
                  ),
                  ExploreIcon(
                    icon: Icons.favorite,
                    label: "Wellness",
                    onTap: () => _go(context, const WellnessPage()),
                  ),
                  ExploreIcon(
                    icon: Icons.bar_chart,
                    label: "Stats",
                    onTap: () => _go(context, const InsightsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

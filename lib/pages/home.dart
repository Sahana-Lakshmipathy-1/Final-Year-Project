import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/tracker.dart';
import 'package:lumora/pages/wellness.dart';

import 'package:lumora/layouts/home/today_focus.dart';
import 'package:lumora/layouts/home/progress.dart';
import 'package:lumora/layouts/home/smart_action.dart';
import 'package:lumora/layouts/home/explore_icon.dart';
import 'package:lumora/layouts/home/today_meal.dart';

class HomeScreen extends StatelessWidget {
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
              /// GREETING
              Text("Good evening, Sahana", style: AppTheme.h1),
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
                      onTap: () => _go(context, const TrackerScreen()),
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

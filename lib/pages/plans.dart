import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/exercise/input_preference.dart';
import 'package:lumora/layouts/exercise/manual_routine_setup_screen.dart';
import 'package:lumora/layouts/meals/meal_input_preference.dart';
import 'package:lumora/layouts/meals/manual_meal_setup_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _activeTab = 0; // 0 = Fitness, 1 = Meals

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isFitness = _activeTab == 0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ------------------------------------------------------------
              /// HEADER
              /// ------------------------------------------------------------
              Text("Your plans", style: AppTheme.h1),
              const SizedBox(height: 6),
              Text(
                "Create and manage your fitness and nutrition routines.",
                style: AppTheme.bodyMuted,
              ),

              const SizedBox(height: 28),

              /// ------------------------------------------------------------
              /// DOMAIN SWITCH (Fitness / Meals)
              /// ------------------------------------------------------------
              _PlanDomainSwitch(
                activeIndex: _activeTab,
                onChanged: (i) => setState(() => _activeTab = i),
              ),

              const SizedBox(height: 24),

              /// ------------------------------------------------------------
              /// PRIMARY ACTION CARD
              /// ------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.elevatedCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFitness
                          ? "Build your fitness plan"
                          : "Build your meal plan",
                      style: AppTheme.h2,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFitness
                          ? "Let AI personalize workouts or create your own routine."
                          : "Get AI-generated meals or plan them manually.",
                      style: AppTheme.bodyMuted,
                    ),

                    const SizedBox(height: 20),

                    /// PRIMARY CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppTheme.primaryButton,
                        onPressed: () {
                          _go(
                            context,
                            isFitness
                                ? const InputPreference()
                                : const MealInputPreference(),
                          );
                        },
                        child: const Text(
                          "Generate with AI ✨",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// SECONDARY CTA
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: AppTheme.ghostButton,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => isFitness
                                  ? const ManualRoutineSetupScreen()
                                  : const ManualMealSetupScreen(),
                            ),
                          );

                          if (result != null) {
                            debugPrint(
                              isFitness
                                  ? "Manual fitness plan: $result"
                                  : "Manual meal plan: $result",
                            );
                          }
                        },
                        child: const Text(
                          "Create manually",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// DOMAIN SWITCH (Senior alternative to DIY tabs)
/// ----------------------------------------------------------------------
class _PlanDomainSwitch extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const _PlanDomainSwitch({
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.card,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _TabItem(
            label: "Fitness",
            isActive: activeIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            label: "Meals",
            isActive: activeIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary.withOpacity(.15) : null,
            borderRadius: AppTheme.radiusMedium,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.primary : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}

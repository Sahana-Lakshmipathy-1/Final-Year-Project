import 'package:flutter/material.dart';
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
  int _activeTabIndex = 0; // 0 = Fitness, 1 = Meals

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F1431);
    const cardEdge = Color(0xFF262A59);
    const muted = Color(0xFFB7C0E0);
    const accent = Color(0xFFB787FF);
    const btnColor = Color(0xFF6F59FF);
    const btnGhost = Color(0xFF2A2E58);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                "Your Plans",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Manage your fitness and nutrition.",
                style: TextStyle(color: muted, fontSize: 16),
              ),
              const SizedBox(height: 22),

              /// TABS
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab("Fitness", 0, accent),
                    const SizedBox(width: 40),
                    _buildTab("Meals", 1, accent),
                  ],
                ),
              ),

              /// MAIN CARD
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(35, 39, 95, 0.9),
                      Color.fromRGBO(28, 31, 70, 0.9),
                    ],
                  ),
                  border: Border.all(color: cardEdge),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 30,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CARD TITLE
                    Text(
                      _activeTabIndex == 0
                          ? "Create a New Fitness Plan"
                          : "Create a New Meal Plan",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// ACTION BUTTONS
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildUseAIButton(btnColor),
                        _buildManualButton(btnGhost),
                      ],
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

  /// USE AI BUTTON
  Widget _buildUseAIButton(Color btnColor) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              if (_activeTabIndex == 0) {
                return const InputPreference();
              }
              return const MealInputPreference();
            },
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(140, 48),
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: btnColor.withOpacity(0.35),
        elevation: 6,
      ),
      child: const Text(
        "Use AI ✨",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  /// CREATE MANUALLY BUTTON
  Widget _buildManualButton(Color btnGhost) {
    return OutlinedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              if (_activeTabIndex == 0) {
                return const ManualRoutineSetupScreen();
              }
              return const ManualMealSetupScreen();
            },
          ),
        );

        if (result != null) {
          debugPrint(
            _activeTabIndex == 0
                ? 'Manual fitness routine: $result'
                : 'Manual meal routine: $result',
          );
        }
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(140, 48),
        backgroundColor: btnGhost,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF343A6A)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Create Manually",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  /// TAB BUILDER
  Widget _buildTab(String label, int index, Color accent) {
    final isActive = _activeTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isActive ? accent : const Color(0xFFAEB6DA),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isActive ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

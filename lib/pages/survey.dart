import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/survey/survey_stepper.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/main_screen.dart';

class SurveyPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const SurveyPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final ApiService _api = ApiService();
  bool _isLoading = false;

  // --- STATS ---
  int _age = 25;
  int _weight = 70;
  int _height = 175;

  // --- SELECTIONS ---
  final List<String> _selectedHealthConditions = [];
  final List<String> _selectedFitnessGoals = [];
  final List<String> _selectedNutritionGoals = [];

  // --- OPTIONS DATA ---
  final List<String> _healthOptions = [
    "Anxiety",
    "Depression",
    "Insomnia",
    "Diabetes",
    "High BP",
    "Asthma",
    "None",
  ];

  final List<String> _fitnessOptions = [
    "Lose Weight",
    "Build Muscle",
    "Improve Stamina",
    "Flexibility",
    "Stay Active",
  ];

  final List<String> _nutritionOptions = [
    "High Protein",
    "Low Carb",
    "Keto",
    "Vegan",
    "Balanced",
    "Vegetarian",
  ];

  // --- LOGIC ---
  void _updateValue(String field, int delta, int min, int max) {
    setState(() {
      switch (field) {
        case 'age':
          _age = (_age + delta).clamp(min, max);
          break;
        case 'weight':
          _weight = (_weight + delta).clamp(min, max);
          break;
        case 'height':
          _height = (_height + delta).clamp(min, max);
          break;
      }
    });
  }

  void _toggleSelection(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  // --- FINAL API CALL ---
  Future<void> _completeSignUp() async {
    setState(() => _isLoading = true);

    try {
      print("🚀 Creating account for ${widget.email}...");
      print("Health: $_selectedHealthConditions");
      print("Fitness: $_selectedFitnessGoals");

      await _api.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        age: _age,
        weight: _weight.toDouble(),
        height: _height.toDouble(),
        // Pass the new lists to the API
        healthConditions: _selectedHealthConditions,
        fitnessGoals: _selectedFitnessGoals,
        nutritionGoals: _selectedNutritionGoals,
      );

      print("✅ Account Created!");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(userName: widget.name)),
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "One Last Step! 🏁",
                  style: AppTheme.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Personalize your wellness profile for ${widget.name}.",
                  style: AppTheme.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // --- 1. BASIC STATS ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.card,
                  child: Column(
                    children: [
                      SurveyStepper(
                        label: "Age",
                        value: _age,
                        min: 10,
                        max: 100,
                        onChanged: (d) => _updateValue('age', d, 10, 100),
                      ),
                      const SizedBox(height: 24),
                      SurveyStepper(
                        label: "Weight (kg)",
                        value: _weight,
                        min: 30,
                        max: 200,
                        onChanged: (d) => _updateValue('weight', d, 30, 200),
                      ),
                      const SizedBox(height: 24),
                      SurveyStepper(
                        label: "Height (cm)",
                        value: _height,
                        min: 100,
                        max: 250,
                        onChanged: (d) => _updateValue('height', d, 100, 250),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. HEALTH CONDITIONS ---
                _buildSectionTitle("Any health conditions?"),
                _buildChipGroup(_healthOptions, _selectedHealthConditions),

                const SizedBox(height: 24),

                // --- 3. FITNESS GOALS ---
                _buildSectionTitle("Fitness Goals"),
                _buildChipGroup(_fitnessOptions, _selectedFitnessGoals),

                const SizedBox(height: 24),

                // --- 4. NUTRITION GOALS ---
                _buildSectionTitle("Nutrition Goals"),
                _buildChipGroup(_nutritionOptions, _selectedNutritionGoals),

                const SizedBox(height: 40),

                // --- SUBMIT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Finish & Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTheme.h3,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildChipGroup(List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => _toggleSelection(selectedList, option),
          backgroundColor: AppTheme.cardBg,
          selectedColor: AppTheme.primary.withOpacity(0.9),
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppTheme.primary : AppTheme.borderSoft,
            ),
          ),
        );
      }).toList(),
    );
  }
}

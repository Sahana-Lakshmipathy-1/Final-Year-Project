import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/main_screen.dart';

class UserPreferencePage extends StatefulWidget {
  // 1. ✅ DEFINE ALL FIELDS HERE
  final String name;
  final String email;
  final String password;
  final int age;
  final double weight;
  final double height;

  const UserPreferencePage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.weight,
    required this.height,
  });

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  final ApiService _api = ApiService();
  bool _isLoading = false;

  // Goals & Conditions
  final List<String> _selectedConditions = [];
  final List<String> _selectedFitnessGoals = [];
  final List<String> _selectedNutritionGoals = [];

  // Options
  final List<String> _healthOptions = [
    "Anxiety",
    "Depression",
    "Insomnia",
    "Diabetes",
    "None",
  ];
  final List<String> _fitnessOptions = [
    "Lose Weight",
    "Build Muscle",
    "Better Sleep",
    "Reduce Stress",
  ];
  final List<String> _nutritionOptions = [
    "Balanced",
    "Keto",
    "Vegan",
    "High Protein",
  ];

  void _toggleSelection(List<String> list, String item) {
    setState(() {
      list.contains(item) ? list.remove(item) : list.add(item);
    });
  }

  Future<void> _completeSignUp() async {
    setState(() => _isLoading = true);

    try {
      print("Creating Account for ${widget.name}...");

      // 2. ✅ CALL API WITH ALL DATA
      await _api.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name, // Now this works!
        age: widget.age,
        weight: widget.weight,
        height: widget.height,
        healthConditions: _selectedConditions,
        fitnessGoals: _selectedFitnessGoals,
        nutritionGoals: _selectedNutritionGoals,
      );

      print("✅ Success!");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            // 3. ✅ Pass name to MainScreen
            builder: (_) => MainScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.danger,
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
        title: const Text("Your Goals"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Last step, ${widget.name}!", style: AppTheme.h2),
              const SizedBox(height: 8),
              Text("Select what applies to you.", style: AppTheme.bodyMuted),

              const SizedBox(height: 32),

              _buildSection(
                "Health Conditions",
                _healthOptions,
                _selectedConditions,
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Fitness Goals",
                _fitnessOptions,
                _selectedFitnessGoals,
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Nutrition",
                _nutritionOptions,
                _selectedNutritionGoals,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _completeSignUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finish Setup"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => _toggleSelection(selected, option),
              backgroundColor: AppTheme.cardBg,
              selectedColor: AppTheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

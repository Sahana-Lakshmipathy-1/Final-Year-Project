import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  // --- 1. SLEEP ---
  TimeOfDay? bedtime;
  TimeOfDay? wakeTime;
  String? sleepQuality;
  String sleepNotes = "";

  // --- 2. MOOD & ENERGY ---
  double energyLevel = 3;
  double stressLevel = 2;
  double focusLevel = 3;
  double irritabilityLevel = 1;
  bool feltSupported = true;

  // --- 3. NUTRITION ---
  String? dietCompliance;
  int mealsLogged = 3;
  int waterCups = 4;
  int caffeineCups = 0;
  TimeOfDay? lastCaffeineTime;
  int alcoholUnits = 0;

  // --- 4. ACTIVITY ---
  int exerciseMinutes = 0;
  String? exerciseIntensity;
  String exerciseTypes = "";
  int outsideMinutes = 0;

  // --- 5. LIFESTYLE ---
  String? screenTime;
  double workloadLevel = 3;
  String? socialInteraction;
  String generalNotes = "";

  // --- OPTIONS ---
  final qualityOptions = ["Restful", "Average", "Restless", "Insomnia"];
  final dietOptions = ["Strict", "Balanced", "Loose", "Off-Track"];
  final intensityOptions = ["Low", "Medium", "High"];
  final screenOptions = ["< 1h", "1-2h", "2-4h", "4h+"];
  final socialOptions = ["None", "Online Only", "One-on-One", "Group/Crowd"];

  // --- HELPERS ---
  String _formatTime(TimeOfDay? time) {
    if (time == null) return "00:00";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  double _calculateSleepHours() {
    if (bedtime == null || wakeTime == null) return 0.0;
    double bed = bedtime!.hour + bedtime!.minute / 60.0;
    double wake = wakeTime!.hour + wakeTime!.minute / 60.0;
    if (wake < bed) {
      wake += 24; // Handle overnight sleep
    }
    return double.parse((wake - bed).toStringAsFixed(1));
  }

  String _inferHydration() {
    if (waterCups >= 8) return "good";
    if (waterCups >= 5) return "average";
    return "poor";
  }

  // --- 🎨 THEME-FIXED TIME PICKER ---
  Future<void> _pickTime(Function(TimeOfDay) onSelect) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.cardBg,
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.cardBg,
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) {
                return states.contains(MaterialState.selected)
                    ? AppTheme.primary
                    : Colors.white;
              }),
              hourMinuteColor: MaterialStateColor.resolveWith((states) {
                return states.contains(MaterialState.selected)
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.cardBgAlt;
              }),
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                return states.contains(MaterialState.selected)
                    ? AppTheme.primary
                    : Colors.transparent;
              }),
              dialHandColor: AppTheme.primary,
              dialBackgroundColor: AppTheme.cardBgAlt,
              dialTextColor: Colors.white,
              cancelButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white70),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(AppTheme.primary),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => onSelect(picked));
    }
  }

  // --- 🚀 SAVE LOGIC WITH COOKIE STORAGE ---
  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final payload = {
        "event_type": "log_adherence",
        "user_id": UserSession.email,
        "payload": {
          "sleep": {
            "bedtime": _formatTime(bedtime),
            "wake_time": _formatTime(wakeTime),
            "quality": sleepQuality ?? "Average",
            "hours": _calculateSleepHours(),
            "notes": sleepNotes,
          },
          "energy_level": energyLevel.toInt(),
          "stress_level": stressLevel.toInt(),
          "focus_level": focusLevel.toInt(),
          "irritability_level": irritabilityLevel.toInt(),
          "felt_supported_today": feltSupported,
          "hydration_level": _inferHydration(),
          "water_intake_cups": waterCups,
          "caffeine_intake": {
            "cups": caffeineCups,
            "last_caffeine_time": _formatTime(lastCaffeineTime),
          },
          "alcohol_intake": {
            "units": alcoholUnits,
            "time": null,
          },
          "physical_activity": {
            "minutes": exerciseMinutes,
            "types": exerciseTypes.isNotEmpty
                ? exerciseTypes.split(',').map((e) => e.trim()).toList()
                : [],
            "intensity": exerciseIntensity?.toLowerCase() ?? "low",
          },
          "outside_time_minutes": outsideMinutes,
          "screen_time_bucket": screenTime ?? "1-2h",
          "workload_level": workloadLevel.toInt(),
          "diet_compliance": dietCompliance?.toLowerCase() ?? "balanced",
          "meals_logged": mealsLogged,
          "social_interaction":
              socialInteraction?.toLowerCase().replaceAll(' ', '_') ?? "none",
          "notes": generalNotes,
        },
      };

      // 1. Call API
      final response = await _api.logAdherence(payload);

      // 2. ✅ EXTRACT ID AND SAVE TO COOKIE (lastJournalId)
      if (response.containsKey('id')) {
        UserSession.setLastJournalId(response['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Daily log saved successfully! ✅"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Daily Check-in", style: AppTheme.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSleepSection(),
              const SizedBox(height: 16),
              _buildMoodSection(),
              const SizedBox(height: 16),
              _buildNutritionSection(),
              const SizedBox(height: 16),
              _buildActivitySection(),
              const SizedBox(height: 16),
              _buildLifestyleSection(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: AppTheme.primaryButton,
                  onPressed: _isLoading ? null : _saveLog,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Daily Log"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION BUILDERS ---

  Widget _buildSleepSection() {
    return _SectionCard(
      title: "Sleep 💤",
      children: [
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: "Bedtime",
                value: bedtime,
                onTap: () => _pickTime((t) => bedtime = t),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: "Wake Up",
                value: wakeTime,
                onTap: () => _pickTime((t) => wakeTime = t),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: "Quality",
          value: sleepQuality,
          items: qualityOptions,
          onChanged: (v) => setState(() => sleepQuality = v),
        ),
        const SizedBox(height: 16),
        TextFormField(
          style: AppTheme.body.copyWith(color: Colors.white),
          decoration: _inputDecoration("Sleep Notes (optional)"),
          onSaved: (v) => sleepNotes = v ?? "",
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return _SectionCard(
      title: "Mood & Mind 🧠",
      children: [
        _SliderField(
          label: "Energy Level",
          value: energyLevel,
          min: 1,
          max: 5,
          onChanged: (v) => setState(() => energyLevel = v),
          emoji: "🔋",
        ),
        _SliderField(
          label: "Stress Level",
          value: stressLevel,
          min: 1,
          max: 5,
          onChanged: (v) => setState(() => stressLevel = v),
          emoji: "🤯",
        ),
        _SliderField(
          label: "Focus",
          value: focusLevel,
          min: 1,
          max: 5,
          onChanged: (v) => setState(() => focusLevel = v),
          emoji: "🎯",
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Felt supported today?",
            style: AppTheme.body.copyWith(color: Colors.white),
          ),
          value: feltSupported,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.primary,
          onChanged: (v) => setState(() => feltSupported = v),
        ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return _SectionCard(
      title: "Nutrition & Hydration 🍎",
      children: [
        _DropdownField(
          label: "Diet Compliance",
          value: dietCompliance,
          items: dietOptions,
          onChanged: (v) => setState(() => dietCompliance = v),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Counter(
              label: "Meals Logged",
              value: mealsLogged,
              onChanged: (v) => setState(() => mealsLogged = v),
            ),
            _Counter(
              label: "Water (Cups)",
              value: waterCups,
              onChanged: (v) => setState(() => waterCups = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Counter(
                label: "Caffeine (Cups)",
                value: caffeineCups,
                onChanged: (v) => setState(() => caffeineCups = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: "Last Caffeine",
                value: lastCaffeineTime,
                onTap: () => _pickTime((t) => lastCaffeineTime = t),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Counter(
          label: "Alcohol (Units)",
          value: alcoholUnits,
          onChanged: (v) => setState(() => alcoholUnits = v),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return _SectionCard(
      title: "Physical Activity 🏃‍♂️",
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: AppTheme.body.copyWith(color: Colors.white),
                decoration: _inputDecoration("Duration (min)"),
                onSaved: (v) => exerciseMinutes = int.tryParse(v ?? "0") ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: "Intensity",
                value: exerciseIntensity,
                items: intensityOptions,
                onChanged: (v) => setState(() => exerciseIntensity = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          style: AppTheme.body.copyWith(color: Colors.white),
          decoration: _inputDecoration("Types (e.g. Gym, Run, Yoga)"),
          onSaved: (v) => exerciseTypes = v ?? "",
        ),
        const SizedBox(height: 12),
        TextFormField(
          keyboardType: TextInputType.number,
          style: AppTheme.body.copyWith(color: Colors.white),
          decoration: _inputDecoration("Time Outside (min)"),
          onSaved: (v) => outsideMinutes = int.tryParse(v ?? "0") ?? 0,
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _SectionCard(
      title: "Lifestyle 💻",
      children: [
        Row(
          children: [
            Expanded(
              child: _DropdownField(
                label: "Screen Time",
                value: screenTime,
                items: screenOptions,
                onChanged: (v) => setState(() => screenTime = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: "Social",
                value: socialInteraction,
                items: socialOptions,
                onChanged: (v) => setState(() => socialInteraction = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SliderField(
          label: "Workload",
          value: workloadLevel,
          min: 1,
          max: 5,
          onChanged: (v) => setState(() => workloadLevel = v),
          emoji: "💼",
        ),
        const SizedBox(height: 16),
        TextFormField(
          minLines: 2,
          maxLines: 4,
          style: AppTheme.body.copyWith(color: Colors.white),
          decoration: _inputDecoration("General Notes / Thoughts"),
          onSaved: (v) => generalNotes = v ?? "",
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppTheme.bg,
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: const BorderSide(color: Colors.white30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }
}

// --- HELPER CLASSES ---

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.elevatedCard.copyWith(
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.h3.copyWith(color: Colors.white)),
          const Divider(color: Colors.white10, height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          border: Border.all(color: Colors.white30),
          borderRadius: AppTheme.radiusSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value?.format(context) ?? "--:--",
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: AppTheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min, max;
  final ValueChanged<double> onChanged;
  final String emoji;
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label $emoji",
              style: AppTheme.body.copyWith(color: Colors.white),
            ),
            Text(
              "${value.toInt()}/5",
              style: AppTheme.h3.copyWith(color: AppTheme.primary),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppTheme.primary,
          inactiveColor: Colors.white12,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownColor: AppTheme.cardBg,
      style: AppTheme.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppTheme.bg,
        border: OutlineInputBorder(
          borderRadius: AppTheme.radiusSmall,
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusSmall,
          borderSide: const BorderSide(color: Colors.white30),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _Counter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.caption.copyWith(color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => onChanged(value > 0 ? value - 1 : 0),
                child: const Icon(
                  Icons.remove,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text("$value", style: AppTheme.h3.copyWith(color: Colors.white)),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.add, color: AppTheme.primary, size: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

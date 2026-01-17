import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? bedtime;
  TimeOfDay? wakeTime;
  String? sleepQuality;
  String notes = "";

  final qualityOptions = const [
    "😴 Excellent",
    "😊 Good",
    "😐 Average",
    "😟 Poor",
    "😩 Very Poor",
  ];

  Future<void> _pickTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isBedtime ? "Select bedtime" : "Select wake-up time",
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          bedtime = picked;
        } else {
          wakeTime = picked;
        }
      });
    }
  }

  void _saveSleep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sleep log saved 💤"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // TODO: Persist sleep data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primary),
        title: Text("Sleep Tracker", style: AppTheme.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: AppTheme.elevatedCard,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("How did you sleep?", style: AppTheme.h1),
                const SizedBox(height: 6),
                Text(
                  "Log your sleep to help the AI understand your energy and mood patterns.",
                  style: AppTheme.bodyMuted,
                ),

                const SizedBox(height: 24),

                _Field(
                  label: "Bedtime",
                  child: _TimeField(
                    value: bedtime,
                    placeholder: "Select bedtime",
                    onTap: () => _pickTime(true),
                  ),
                ),

                _Field(
                  label: "Wake-up time",
                  child: _TimeField(
                    value: wakeTime,
                    placeholder: "Select wake-up time",
                    onTap: () => _pickTime(false),
                  ),
                ),

                _Field(
                  label: "Sleep quality",
                  child: DropdownButtonFormField<String>(
                    value: sleepQuality,
                    dropdownColor: AppTheme.cardBg,
                    style: AppTheme.body,
                    decoration: _inputDecoration(),
                    items: qualityOptions
                        .map(
                          (q) => DropdownMenuItem(
                            value: q,
                            child: Text(q),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => sleepQuality = v),
                    validator: (v) =>
                        v == null ? "Please select a quality" : null,
                  ),
                ),

                _Field(
                  label: "Notes (optional)",
                  child: TextFormField(
                    minLines: 3,
                    maxLines: 6,
                    style: AppTheme.body,
                    decoration: _inputDecoration().copyWith(
                      hintText:
                          "Dreams, interruptions, how you felt waking up…",
                    ),
                    onSaved: (v) => notes = v ?? "",
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButton,
                    onPressed: _saveSleep,
                    child: const Text(
                      "Save Sleep Log",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.cardBg,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: BorderSide(color: AppTheme.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: BorderSide(color: AppTheme.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusSmall,
        borderSide: BorderSide(color: AppTheme.primary, width: 1.4),
      ),
      hintStyle: AppTheme.caption,
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               HELPER WIDGETS                               */
/* -------------------------------------------------------------------------- */

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TimeOfDay? value;
  final String placeholder;
  final VoidCallback onTap;

  const _TimeField({
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: AppTheme.radiusSmall,
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? value!.format(context) : placeholder,
              style: AppTheme.body,
            ),
            Icon(Icons.schedule, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? _bedtime;
  TimeOfDay? _wakeTime;
  String _sleepQuality = "";
  String _notes = "";

  final List<String> qualityOptions = [
    "😴 Excellent",
    "😊 Good",
    "😐 Average",
    "😟 Poor",
    "😩 Very Poor",
  ];

  Future<void> _pickTime({required bool isBedtime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isBedtime ? 'Select Bedtime' : 'Select Wake Time',
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sleep data saved successfully 💤"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // TODO: Store or send sleep data to backend
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0F1431);
    const Color card = Color(0xFF1E2248);
    const Color accent = Color(0xFFB787FF);
    const Color muted = Color(0xFFB7C0E0);
    const Color edge = Color(0xFF2C315C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C3A),
        title: const Text(
          "Sleep Tracker 😴",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card.withOpacity(0.9),
              border: Border.all(color: edge),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Track Your Sleep",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Record your bedtime, wake-up time, and how you felt upon waking.",
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 20),

                // Bedtime Picker
                _buildField(
                  label: "Bedtime",
                  child: GestureDetector(
                    onTap: () => _pickTime(isBedtime: true),
                    child: _buildInputBox(
                      text: _bedtime != null
                          ? _bedtime!.format(context)
                          : "Select bedtime",
                    ),
                  ),
                ),

                // Wake Time Picker
                _buildField(
                  label: "Wake-up time",
                  child: GestureDetector(
                    onTap: () => _pickTime(isBedtime: false),
                    child: _buildInputBox(
                      text: _wakeTime != null
                          ? _wakeTime!.format(context)
                          : "Select wake-up time",
                    ),
                  ),
                ),

                // Sleep Quality Dropdown
                _buildField(
                  label: "How was your sleep?",
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF14183A),
                    decoration: _inputDecoration(),
                    value: _sleepQuality.isEmpty ? null : _sleepQuality,
                    items: qualityOptions
                        .map(
                          (q) => DropdownMenuItem(
                            value: q,
                            child: Text(
                              q,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _sleepQuality = value ?? "");
                    },
                    validator: (value) =>
                        value == null ? "Please select one" : null,
                  ),
                ),

                // Notes Textarea
                _buildField(
                  label: "Notes or dreams (optional)",
                  child: TextFormField(
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration().copyWith(
                      hintText:
                          "Describe how you felt waking up, any dreams, or interruptions...",
                    ),
                    onSaved: (val) => _notes = val ?? "",
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  onPressed: _submitForm,
                  child: const Center(
                    child: Text(
                      "Save Sleep Log",
                      style: TextStyle(
                        color: Color(0xFF1A1034),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
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

  Widget _buildField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD8DCFF),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInputBox({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14183A),
        border: Border.all(color: const Color(0xFF2B2F58)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          const Icon(Icons.schedule, color: Color(0xFFB7C0E0)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0F1331),
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2B2F58)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2B2F58)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB787FF), width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9FA8D2), fontSize: 14),
    );
  }
}

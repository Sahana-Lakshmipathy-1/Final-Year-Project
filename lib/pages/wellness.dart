import 'package:flutter/material.dart';
import "package:lumora/layouts/wellness/sleep_tracker.dart";
import "package:lumora/layouts/wellness/mood_analysis.dart";
import "package:lumora/layouts/wellness/wellness_bot.dart";

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  int selectedMoodIndex = 4; // default 😁

  final moods = ["😩", "😟", "😐", "😊", "😁"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1431),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Wellness Center",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFeef1ff),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Check in with your feelings.",
                style: TextStyle(
                  color: Color(0xFFb7c0e0),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Picker Card
              _buildCard(
                title: "How are you feeling?",
                child: SizedBox(
                  width: double.infinity, // ✅ take full width of card
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween, // ✅ spread evenly
                    runSpacing: 12,
                    children: List.generate(moods.length, (i) {
                      final isActive = selectedMoodIndex == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedMoodIndex = i);
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF202657),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFFb787ff)
                                  : const Color(0xFF313873),
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            moods[i],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Mood Analysis Card
              _buildCard(
                title: "Recent Mood Analysis",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Click ‘Analyze’ to get an AI summary of recent moods.",
                      style: TextStyle(color: Color(0xFFb7c0e0)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8b6bff),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: const Color(0xFF8b6bff).withOpacity(.35),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoodInsightsPage(),
                          ),
                        );
                      },

                      child: const Center(
                        child: Text(
                          "Analyze with AI ✨",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFf4edff),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sleep Tracker Card ⬇️
              _buildCard(
                title: "Sleep Tracker 😴",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Track your sleep patterns, understand your rest cycles, and improve your bedtime habits over time.",
                      style: TextStyle(
                        color: Color(0xFFb7c0e0),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8b6bff),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: const Color(0xFF8b6bff).withOpacity(.35),
                        elevation: 6,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SleepTrackerPage(),
                          ),
                        );
                      },

                      child: const Center(
                        child: Text(
                          "Track My Sleep",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFf4edff),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Support Card
              _buildCard(
                title: "AetherWell Support",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Need to speak out?",
                      style: TextStyle(color: Color(0xFFb7c0e0)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8b6bff),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WellnessChatPage(),
                          ),
                        );
                      },

                      child: const Center(
                        child: Text(
                          "Talk with our wellness bot",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFf4edff),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Meditation page
                  },
                  child: const Text(
                    "Looking for meditation?",
                    style: TextStyle(
                      color: Color(0xFFb787ff),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(230, 35, 39, 95),
            Color.fromARGB(230, 28, 31, 70),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFF262a59)),
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
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

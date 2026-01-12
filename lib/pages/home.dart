import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0D0D25);
    const labelColor = Color(0xFFEFEFFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                "Good Evening, Sahana!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's your summary for today.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Today’s Workout Card
              _buildCard(
                title: "Today's Workout",
                subtitle: "No active fitness plan.",
                buttonText: "Go to Plans",
              ),
              const SizedBox(height: 16),

              // Mood + Emergency Row
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      title: "Mood Check-in",
                      subtitle: "No mood logged yet today.",
                      buttonText: "Log Mood",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      title: "Emergency",
                      subtitle: "Access SOS and first aid.",
                      buttonText: "SOS Center",
                      buttonColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Actions
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.bar_chart,
                      label: "View Insights",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.calendar_today,
                      label: "Manage Plans",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String buttonText,
    Color buttonColor = const Color(0xFF232E40),
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151533),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onPressed: () {},
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151533),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

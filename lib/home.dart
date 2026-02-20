import 'package:flutter/material.dart';
import 'mood_diary.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _todayMoodCard(),
                    const SizedBox(height: 16),
                    _moodDiaryButton(context),
                    const SizedBox(height: 16),

                    _menuCard(
                      title: 'Mood Tracking',
                      subtitle: 'How are you feeling today?',
                      icon: '😊',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MoodDiaryPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _menuCard(
                      title: 'Deep Breathing',
                      subtitle: 'Relax in 2 minutes',
                      icon: '🪷',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),

                    _menuCard(
                      title: 'Psychiatrist Chat',
                      subtitle: 'Talk to a professional',
                      icon: '💗',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MindCare+',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TODAY MOOD ----------------
  Widget _todayMoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'นันทิชา ☀️',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "You're doing great today.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodDiaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodDiaryPage()),
          );
        },
        icon: const Icon(Icons.menu_book_rounded),
        label: const Text(
          'Open Mood Diary',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------------- MENU CARD ----------------
  Widget _menuCard({
    required String title,
    required String subtitle,
    required String icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Colors.teal),
          Icon(Icons.self_improvement),
          Icon(Icons.chat_bubble_outline),
          Icon(Icons.person_outline),
        ],
      ),
    );
  }
}

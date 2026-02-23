import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/mood/mood_calendar.dart';
import 'package:mindcare/features/profile/profile_screen.dart';
import 'package:mindcare/features/meditation/meditation_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// ---------------- GREETING ----------------
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning ☀️";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 🌤";
    } else {
      return "Good Evening 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลผู้ใช้")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFF2F5F7),
          body: SafeArea(
            child: Column(
              children: [
                _header(context),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _todayMoodCard(firstName),
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
                                builder: (_) => const MoodCalendarPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _menuCard(
                          title: 'Deep Breathing',
                          subtitle: 'Relax in 5 minutes',
                          icon: '🪷',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MeditationPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _menuCard(
                          title: 'Psychiatrist Chat',
                          subtitle: 'Talk to a professional',
                          icon: '💗',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PsychiatristPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
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
            children: [
              const Icon(Icons.notifications_none),
              const SizedBox(width: 12),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Log out',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TODAY MOOD ----------------
  Widget _todayMoodCard(String firstName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '$firstName ✨',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
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
}
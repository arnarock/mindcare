import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/features/mood/mood_calendar.dart';
import 'package:mindcare/features/meditation/meditation_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _autoSlide();
  }

  void _autoSlide() {
    Future.delayed(const Duration(seconds: 5), () {

      if (!mounted) return;

      _page++;

      if (_page > 1) {
        _page = 0;
      }

      if (_controller.hasClients) {
        _controller.animateToPage(
          _page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }

      _autoSlide();
    });
  }

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

        return AppLayout(
          isHome: true,
          child: Container(
            color: const Color(0xFFF2F5F7),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _greetingCard(firstName),

                        const SizedBox(height: 16),

                        _inspirationCard(),

                        const SizedBox(height: 16),

                        Row(
                          children: [

                            Expanded(
                              child: SizedBox(
                                height: 140,
                                child: _moodSummaryCard(),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: SizedBox(
                                height: 140,
                                child: _streakCard(),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 16),

                        _menuCard(
                          title: 'Mood Tracking',
                          subtitle: 'How are you feeling today?',
                          icon: '😊',
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFDFF6FF),
                              Color(0xFFB8E8FC)
                            ],
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

                        const SizedBox(height: 14),

                        _menuCard(
                          title: 'Deep Breathing',
                          subtitle: 'Relax in 5 minutes',
                          icon: '🪷',
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE8F8F5),
                              Color(0xFFC8E6C9)
                            ],
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

                        const SizedBox(height: 14),

                        _menuCard(
                          title: 'Psychiatrist Chat',
                          subtitle: 'Talk to a professional',
                          icon: '💗',
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE3F2FD),
                              Color(0xFFBBDEFB)
                            ],
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

                        const SizedBox(height: 30),
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

  Widget _inspirationCard() {
    return SizedBox(
      height: 90,
      child: PageView(
        controller: _controller,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Daily Inspiration",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("Small steps every day lead to big changes."),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF3E0),
                  Color(0xFFFFE0B2),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mental Health Tip",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("Take 5 deep breaths when you feel stressed."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _greetingCard(String firstName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage("assets/images/bg/greeting.png"),
          fit: BoxFit.cover,

          // ทำให้พื้นหลังมืดลงเพื่อให้ตัวหนังสือชัด
          colorFilter: ColorFilter.mode(
            Colors.black38,
            BlendMode.darken,
          ),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_getGreeting()},",
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(0,2),
                    )
                  ],
                ),
              ),
              Text(
                "$firstName ✨",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                      offset: Offset(0,3),
                    )
                  ],
                ),
              ),
              const Text(
                "Take a deep breath today",
                style: TextStyle(
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(0,2),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _moodSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Mood Summary",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Icon(Icons.show_chart, size: 40, color: Colors.blue),
          SizedBox(height: 10),
          Text("80% Healthy days"),
        ],
      ),
    );
  }

  Widget _streakCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Meditation Streak",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("🙂🙂🙂 → 3d", style: TextStyle(fontSize: 18)),
          SizedBox(height: 6),
          Text("Great job!"),
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.black54)),
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
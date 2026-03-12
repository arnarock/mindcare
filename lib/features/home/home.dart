import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/core/constants/mood_images.dart';
import 'package:mindcare/core/services/mood_stats_service.dart';
import 'package:mindcare/core/services/mood_notification_helper.dart';
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

  String _moodMessage(double avg) {
    if (avg >= 4) {
      return "You're shining this month ✨";
    }
    if (avg >= 2) {
      return "You're doing great, keep it up 💙";
    }
    if (avg >= 0) {
      return "Things seem balanced and calm 🌿";
    }
    if (avg >= -2) {
      return "Take a little time for yourself today 🤍";
    }
    return "It's okay to slow down and rest 💛";
  }

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
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';

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
                          iconPath: 'assets/images/home/mood_tracking_icon.png',
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
                          title: 'Meditation',
                          subtitle: 'Relax in 5 minutes',
                          iconPath: 'assets/images/home/meditation_icon.png',
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
                          iconPath: 'assets/images/home/psychiatrist_icon.png',
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

                        const SizedBox(height: 14),
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
                Text(
                  "Daily Inspiration",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),

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
                Text(
                  "Mental Health Tip",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                    )
                  ),

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
            child: Icon(
              Icons.person, 
              color: Colors.white
            ),
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
    return FutureBuilder<double>(
      future: MoodStatsService.getAverageMood(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No mood data"));
        }

        double avg = snapshot.data!;

        String mood = MoodNotificationHelper.scoreToMood(avg);

        String image =
            MoodImages.map[mood] ??
            "assets/images/moods/mood_calm.png";

        const months = [
          '',
          'January','February','March','April','May','June',
          'July','August','September','October','November','December'
        ];

        String month = months[DateTime.now().month];

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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mood Summary • $month",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Image.asset(
                image,
                height: 32,
              ),

              const SizedBox(height: 6),

              Text(
                _moodMessage(avg),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
          Text(
            "Meditation Streak",
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
          ),

          SizedBox(height: 10),

          Text(
            "Your calm habit is growing", 
            style: TextStyle(
              color: Colors.black45,
              fontSize: 13
            )
          ),

          SizedBox(height: 6),
          
          Text(
            "Great job!",
            style: TextStyle(
              fontSize: 14
            )
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required String iconPath,
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
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54
                    )
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
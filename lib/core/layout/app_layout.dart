import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mindcare/features/home/home.dart';
import 'package:mindcare/features/profile/profile_screen.dart';
import 'package:mindcare/core/services/mood_notification_helper.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool isHome;
  final bool hideProfile;

  const AppLayout({
    super.key,
    required this.child,
    this.isHome = false,
    this.hideProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// LOGO
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isHome
                ? null
                : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                      (route) => false,
                    );
                  },
            child: Text(
              'MindCare+',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isHome ? Colors.grey : Colors.teal,
              ),
            ),
          ),

          Row(
            children: [

              /// NOTIFICATION
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () async {
                  try {
                    await MoodNotificationHelper
                        .sendTodayMoodNotification();
                  } catch (e) {
                    debugPrint("Notification error: $e");
                  }
                },
              ),

              /// PROFILE
              if (!hideProfile)
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

              /// LOGOUT (เฉพาะหน้า Home)
              if (isHome)
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
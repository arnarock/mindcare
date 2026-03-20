/*
* File: app_layout.dart
* Description: Provides a reusable application layout with a header including logo navigation, notifications, profile access, and optional logout, wrapping the main content area for both user and admin views.
*
* Responsibilities:
* - สร้าง Layout หลักของแอปพร้อม SafeArea และ Column
* - แสดง Header ประกอบด้วย Logo, ปุ่มแจ้งเตือน, ปุ่มเข้า Profile, และ Logout (ถ้าเป็นหน้า Home)
* - โลโก้สามารถนำทางไปหน้า Home หรือ Admin Home ตาม role ของผู้ใช้
* - ปุ่ม Notification เรียก MoodNotificationHelper เพื่อส่งการแจ้งเตือนรายวัน
* - ปุ่ม Profile นำไปหน้า ProfileScreen
* - ปุ่ม Logout ออกจากระบบและกลับไปหน้า Login
* - รองรับการซ่อนปุ่ม Profile และการกำหนดหน้า Home
*
* Authors: <Anajak Chuamuangphan/ zoozoo>
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/services/mood_notification_helper.dart';
import 'package:mindcare/features/home/home.dart';
import 'package:mindcare/features/profile/profile_screen.dart';
import 'package:mindcare/features/admin/admin_home_page.dart';

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
            onTap: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;

              if (uid == null) return;

              final doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();

              final role = doc.data()?['role'] ?? 'user';

              if (!context.mounted) return;

              if (role == "admin") {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminHomePage(),
                  ),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Image.asset(
              'assets/images/logo/logo_with_name.png',
              width: 35,
              height: 35,
              fit: BoxFit.contain,
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
                    child: Icon(
                      Icons.person, 
                      color: Colors.white
                    ),
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
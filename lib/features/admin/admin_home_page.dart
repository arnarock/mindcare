/*
* File: admin_home_page.dart
* Description: Admin dashboard for the MindCare app, providing quick access to user management and chat support features. Displays a personalized greeting and allows navigation to manage users or interact with users via support chats.
*
* Note:
* - Uses FirebaseAuth to identify the currently logged-in admin.
* - Uses Firestore stream to fetch and update user profile data in real-time.
* - Wrapped with AppLayout for consistent application structure.
*
* Lifecycle:
* - build(): Checks authentication state and subscribes to user data via StreamBuilder.
* - Stream updates trigger UI rebuild when user profile data changes.
* - _menuCard(): Builds reusable navigation cards for admin features.
*
* Responsibilities:
* - Display personalized greeting for the admin.
* - Provide navigation to user management and chat support pages.
* - Handle loading, empty, and unauthenticated states.
* - Maintain consistent UI layout using AppLayout.
*
* Authors:
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/features/admin/admin_users_page.dart';
import 'package:mindcare/features/admin/admin_chat_list_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

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
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Hi $firstName ✨",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Welcome to MindCare Admin Panel",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _menuCard(
                    context,
                    icon: Icons.people,
                    title: "Manage Users",
                    subtitle: "จัดการข้อมูลผู้ใช้งาน",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _menuCard(
                    context,
                    icon: Icons.chat,
                    title: "Chat Support",
                    subtitle: "พูดคุยกับผู้ใช้งาน",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminChatListPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Icon(
                  icon, 
                  color: Colors.teal
                ),
              ),

              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios, 
                size: 16
              ),
            ],
          ),
        ),
      ),
    );
  }
}
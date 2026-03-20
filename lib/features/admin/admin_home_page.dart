/*
* File: admin_home_page.dart
* Description: Admin dashboard for the MindCare app, providing quick access to user management and chat support features. Displays a personalized greeting and allows navigation to manage users or interact with users via support chats.
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

/// The main dashboard page for administrators.
///
/// This page retrieves the admin's profile from Firestore
/// and displays a personalized greeting along with navigation
/// options for administrative features.
///
/// Responsibilities:
/// - Display personalized greeting for the admin
/// - Provide navigation to user management and chat support
/// - Handle loading, empty, and unauthenticated states
/// - Maintain consistent UI using [AppLayout]
///
/// Notes:
/// - Requires authenticated user
/// - Designed for admin-role users only
/// - Uses Firestore StreamBuilder for real-time updates
class AdminHomePage extends StatefulWidget {

  /// Creates an [AdminHomePage].
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

/// State class for [AdminHomePage].
///
/// Handles UI rendering and real-time data updates.
class _AdminHomePageState extends State<AdminHomePage> {

  @override
  Widget build(BuildContext context) {

    /// Retrieves the currently authenticated user.
    final user = FirebaseAuth.instance.currentUser;

    /// If no user is logged in, show a login prompt.
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    /// StreamBuilder listens to changes in the user's document
    /// to keep profile data up to date.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),

      builder: (context, snapshot) {

        /// Shows loading indicator while fetching data.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// Displays an error message if user data is missing.
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลผู้ใช้")),
          );
        }

        /// Extracts user profile data.
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
      
        /// Wraps content with the shared application layout.
        return AppLayout(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(20),

              /// Main column containing greeting and menu options.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Personalized greeting message.
                  Text(
                    "Hi $firstName ✨",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Subtitle welcoming admin to the panel.
                  const Text(
                    "Welcome to MindCare Admin Panel",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Menu card for managing users.
                  _menuCard(
                    context,
                    icon: Icons.people,
                    title: "Manage Users",
                    subtitle: "จัดการข้อมูลผู้ใช้งาน",
                    onTap: () {

                      /// Navigates to the AdminUsersPage.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Menu card for chat support.
                  _menuCard(
                    context,
                    icon: Icons.chat,
                    title: "Chat Support",
                    subtitle: "พูดคุยกับผู้ใช้งาน",
                    onTap: () {

                      /// Navigates to the AdminChatListPage.
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

  /// Builds a reusable menu card used for admin navigation.
  ///
  /// Each card displays:
  /// - An icon representing the feature
  /// - A title and subtitle
  /// - A navigation arrow indicator
  ///
  /// When tapped, the provided [onTap] callback is executed.
  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,

      /// Card container providing visual elevation and rounded corners.
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          /// Row layout for icon, text, and arrow.
          child: Row(
            children: [

              /// Circular icon avatar.
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Icon(
                  icon, 
                  color: Colors.teal
                ),
              ),

              const SizedBox(width: 16),
              
              /// Text section containing title and subtitle.
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

              /// Arrow indicating navigation.
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
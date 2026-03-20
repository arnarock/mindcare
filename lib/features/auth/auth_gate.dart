/*
* File: auth_gate.dart
* Description: Authentication gateway that manages user access in the MindCare app. It listens to Firebase Auth state changes, checks the user’s role from Firestore, and directs users to the appropriate screen: login for unauthenticated users, home for regular users, or admin dashboard for administrators.
*
* Responsibilities:
* - ฟังสถานะผู้ใช้จาก Firebase Auth แบบ real-time
* - ตรวจสอบ role ของผู้ใช้จาก Firestore
* - นำทางผู้ใช้ไปยังหน้าที่เหมาะสม: 
*   - LoginScreen สำหรับผู้ใช้ที่ยังไม่ได้เข้าสู่ระบบ
*   - HomePage สำหรับผู้ใช้ปกติ
*   - AdminHomePage สำหรับผู้ดูแลระบบ
* - แสดง loading indicator ขณะรอสถานะผู้ใช้หรือดึงข้อมูล role
*
* Authors: <Anajak Chuamuangphan/ zoozoo>
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/auth/login_screen.dart';
import 'package:mindcare/features/home/home.dart';
import 'package:mindcare/features/admin/admin_home_page.dart';

/// Controls access to the application based on authentication
/// status and user role.
///
/// This widget listens to Firebase Authentication state changes
/// and determines which screen should be displayed:
/// - LoginScreen if the user is not authenticated
/// - AdminHomePage if the user has admin role
/// - HomePage for regular users
///
/// Features:
/// - Real-time authentication monitoring
/// - Role-based navigation using Firestore
/// - Loading indicators during async operations
///
/// Notes:
/// - Serves as the entry point after app startup
/// - Requires Firebase Authentication and Firestore
/// - Prevents unauthorized access to admin features
class AuthGate extends StatelessWidget {

  /// Creates an [AuthGate].
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    /// StreamBuilder listens to authentication state changes
    /// (login, logout, session restore).
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {

        /// Displays loading indicator while checking auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// If no user is signed in, show the login screen.
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        /// Retrieves the authenticated user's UID.
        final uid = snapshot.data!.uid;

        /// FutureBuilder fetches the user's role from Firestore.
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),

          builder: (context, roleSnapshot) {

            /// Shows loading indicator while retrieving role data.
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            /// Extracts user data from the Firestore document.
            final data = roleSnapshot.data?.data() as Map<String, dynamic>?;

            /// Determines the user's role (default is "user").
            final role = data?['role'] ?? 'user';

            /// If the user is an admin, navigate to admin dashboard.
            if (role == "admin") {
              return const AdminHomePage();
            }

            /// Otherwise, navigate to the regular user home page.
            return const HomePage();
          },
        );
      },
    );
  }
}
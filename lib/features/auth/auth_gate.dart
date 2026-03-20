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
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Atitaya Khangtan 650510650
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/auth/login_screen.dart';
import 'package:mindcare/features/home/home.dart';
import 'package:mindcare/features/admin/admin_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = roleSnapshot.data?.data() as Map<String, dynamic>?;

            final role = data?['role'] ?? 'user';

            if (role == "admin") {
              return const AdminHomePage();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}
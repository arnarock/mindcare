/*
* File: profile_screen.dart
* Description: User profile screen displaying personal information (name, email, phone), email verification status, and options to refresh status or log out.
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Atitaya Khangtan 650510650
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/features/auth/login_screen.dart'; 

/// Profile screen that displays user information.
///
/// Responsibilities:
/// - Display user profile data (name, email, phone)
/// - Show email verification status and allow resending verification email
/// - Provide option to refresh user data
/// - Handle user logout and navigation to login screen
/// - Retrieve user data from Firestore in real time
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  /// Reloads the current user from Firebase Auth
  /// Used to update emailVerified status after verification
  Future<void> refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {});
  }

  /// Sends verification email again to the current user
  Future<void> resendVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.sendEmailVerification();

      if (!mounted) return;

      /// Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ส่งอีเมลยืนยันอีกครั้งแล้ว 📩"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Get currently logged-in user
    final user = FirebaseAuth.instance.currentUser;

    /// Listen to user document changes from Firestore in real time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {

        /// Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// If no user data is found
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลผู้ใช้")),
          );
        }

        /// Extract user data from Firestore
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final fullName = "$firstName $lastName";
        final phoneNumber = data['phone'] ?? '';

        return AppLayout(
          hideProfile: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 10),

                /// Profile avatar with shadow decoration
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.25),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.teal,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Display full name
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// Display email from Firebase Auth
                Text(
                  user?.email ?? "-",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 20),

                /// Card containing user information details
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [

                      /// Full name info row
                      _infoCard(
                        icon: Icons.person_pin_rounded,
                        title: "Full Name",
                        value: fullName,
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      /// Phone number info row
                      _infoCard(
                        icon: Icons.call,
                        title: "Phone Number",
                        value: phoneNumber,
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      /// Email info row
                      _infoCard(
                        icon: Icons.email,
                        title: "Email",
                        value: user?.email ?? "-",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Show warning if email is not verified
                if (user != null && !user.emailVerified)
                  _warningCard()
                else
                  _successCard(),

                const SizedBox(height: 20),

                /// Button to refresh verification status
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: refreshUser,
                    child: const Text(
                      "Refresh Status",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- Logout ----------------
                /// Button to log out from the application
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {

                      /// Sign out from Firebase Auth
                      await FirebaseAuth.instance.signOut();

                      if (!mounted) return;

                      /// Navigate to login screen and clear navigation stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
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

  /// Reusable widget for displaying one info row
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Info label
                Text(title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),

                /// Info value
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Warning card shown when email is not verified
  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "อีเมลของคุณยังไม่ได้ยืนยัน",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          /// Button to resend verification email
          ElevatedButton(
            onPressed: resendVerification,
            child: const Text("ส่งอีเมลยืนยันอีกครั้ง"),
          ),
        ],
      ),
    );
  }

  /// Success card shown when email is verified
  Widget _successCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "อีเมลของคุณได้รับการยืนยันแล้ว ✅",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
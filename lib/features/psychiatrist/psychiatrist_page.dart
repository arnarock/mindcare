/*
* File: psychiatrist_page.dart
* Description: Main psychiatrist dashboard page that welcomes the user and provides access to chat with a psychiatrist and view or take mental health self-assessments.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_chat_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment _result.dart';

/// Main page for psychiatric support features
/// - Shows welcome message
/// - Provides access to chat with psychiatrist
/// - Provides access to mental health self-assessment
class PsychiatristPage extends StatelessWidget {
  const PsychiatristPage({super.key});

  @override
  Widget build(BuildContext context) {

    /// Get currently logged-in user
    final user = FirebaseAuth.instance.currentUser;

    /// If no user is logged in → show login required message
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    /// Listen to user's profile data from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {

        /// Show loading indicator while fetching data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator()
            ),
          );
        }

        /// If user data not found → show error message
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text("ไม่พบข้อมูลผู้ใช้")
            ),
          );
        }

        /// Extract user information
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';

        return AppLayout(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= WELCOME TEXT =================

                /// Display user's name
                Text(
                  "Welcome, $firstName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// Subtitle encouraging mental self-care
                const Text(
                  "Take care of yourself with\nPsychological Counselling",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // ================= CHAT OPTION =================

                /// Card to open psychiatrist chat page
                _optionCard(
                  context,
                  icon: Icons.chat_outlined,
                  title: "My Inbox",
                  subtitle: "Chat with Psychiatrist",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PsychiatristChatPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ================= SELF-ASSESSMENT OPTION =================

                /// Card to open mental health self-assessment
                _optionCard(
                  context,
                  icon: Icons.edit_note_outlined,
                  title: "Self Assessments",
                  subtitle: "Mental health evaluation",
                  onTap: () async  {

                    /// Check current user again
                    final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                    /// Check if assessment result already exists
                    final doc = await FirebaseFirestore.instance
                        .collection("self_assessment_results")
                        .doc(user.uid)
                        .get();

                    /// If result exists → open result page
                    if (doc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PsychiatristSelfAssessmentResultPage(),
                        ),
                      );

                    /// Otherwise → open questionnaire page
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PsychiatristSelfAssessmentPage(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  /// Reusable option card widget
  /// Used for navigation to different psychiatric features
  Widget _optionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(

      /// Rounded ripple effect
      borderRadius: BorderRadius.circular(18),

      /// Action when card is tapped
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F9FF),
          borderRadius: BorderRadius.circular(18),

          /// Soft shadow for elevation effect
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            /// Icon inside circular background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.teal, size: 26),
            ),

            const SizedBox(width: 16),

            /// Title and subtitle text
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

            /// Arrow icon indicating navigation
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
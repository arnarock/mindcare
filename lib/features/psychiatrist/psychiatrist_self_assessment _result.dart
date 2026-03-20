/*
* File: psychiatrist_self_assessment_result.dart
* Description: Displays mental health self-assessment results by retrieving data from Firebase Firestore. Shows score interpretation, feedback messages, and provides navigation to chat with a psychiatrist and assessment history.
*
* Authors: 
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_chat_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';

/// Page that displays the result of the mental health self-assessment
/// - Can be viewed by user or admin
/// - Shows score, result level, explanation, and actions
/// 
/// Responsibilities:
/// - Display assessment score and result interpretation.
/// - Show detailed mental health feedback.
/// - Provide navigation to chat with psychiatrist.
/// - Allow users to retake assessment or view history.
/// - Support admin view for monitoring user results.
/// 
/// Note:
/// - Uses Firestore to retrieve assessment results from self_assessment_results/{userId}.
/// - Supports both user view and admin view via [isAdminView].
/// - Displays result interpretation, description, and related UI elements.
/// - Navigates to chat or assessment pages based on user interaction.
/// 
/// Lifecycle:
/// - build(): Subscribes to assessment result data via StreamBuilder.
/// - Stream updates trigger UI rebuild when result data changes.
/// - _getResultThai(): Maps result level to Thai description.
/// - _getDescription(): Provides detailed feedback based on result level.
class PsychiatristSelfAssessmentResultPage extends StatelessWidget {

  /// User ID (used when admin views another user's result)
  final String? userId;

  /// Indicates admin view mode (read-only for another user)
  final bool isAdminView;

  const PsychiatristSelfAssessmentResultPage({
    super.key,
    this.userId,
    this.isAdminView = false,
  });

  /// Convert result level to Thai description text
  String _getResultThai(String result) {
    switch (result) {
      case "Good":
        return "มีสุขภาพจิตดีกว่าคนทั่วไป (Good)";
      case "Fair":
        return "มีสุขภาพจิตเท่ากับคนทั่วไป (Fair)";
      default:
        return "มีสุขภาพจิตต่ำกว่าคนทั่วไป (Poor)";
    }
  }

  /// Detailed explanation text based on result level
  String _getDescription(String result) {
    switch (result) {
      case "Good":
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับดี"
            "สามารถรับมือกับปัญหาในชีวิตประจำวันได้อย่างเหมาะสม"
            "ควรรักษาพฤติกรรมด้านบวกและดูแลสุขภาพจิตอย่างสม่ำเสมอ"
            "การพักผ่อนและทำกิจกรรมที่ชอบจะช่วยเสริมสุขภาวะทางใจให้ดียิ่งขึ้น";
      case "Fair":
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับปานกลาง"
            "อาจมีความเครียดหรือความกังวลในบางช่วงเวลา"
            "ควรดูแลตนเองด้วยการพักผ่อนให้เพียงพอและผ่อนคลายความเครียด"
            "หากรู้สึกไม่สบายใจต่อเนื่องควรปรึกษาผู้เชี่ยวชาญ";
      default:
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับต่ำกว่าคนทั่วไป"
            "อาจกำลังเผชิญกับความเครียดหรือความทุกข์ใจในชีวิตประจำวัน"
            "ควรได้รับการดูแลด้านจิตใจอย่างเหมาะสม"
            "การพูดคุยกับผู้เชี่ยวชาญหรือคนที่ไว้ใจได้จะช่วยให้รู้สึกดีขึ้น"
            "ท่านไม่จำเป็นต้องเผชิญปัญหาเพียงลำพัง";
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Current logged-in user
    final currentUser = FirebaseAuth.instance.currentUser;

    /// Determine which UID to use
    /// - Admin view → use provided userId
    /// - Normal view → use current user's UID
    final uid = isAdminView ? userId : currentUser?.uid;

    /// Listen to assessment result document in Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('self_assessment_results')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {

        /// Show loading while fetching data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        }

        /// If no data found → show error message
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("ไม่พบข้อมูลผู้ใช้")
          );
        }

        /// Extract score and result from Firestore
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final score = data["score"];
        final result = data["result"];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Self Assessment',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Top section showing image, score, and result level
                _resultHeader(score, result),

                const SizedBox(height: 20),

                /// Card containing explanation and chat button
                _resultCard(context, result),

                const SizedBox(height: 20),

                // _criteriaSection(),

                /// Credit information for the assessment source
                _creditSection(),

                const Spacer(),

                /// Retake button only for normal user view
                if (!isAdminView) ...[
                  _retakeAssessmentButton(context),
                  const SizedBox(height: 12),
                ],

                /// View history button
                _historyAssessmentButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header showing result image, score, and summary text
  Widget _resultHeader(int score, String result) {
    String imagePath;

    switch (result) {
      case "Good":
        imagePath = 'assets/images/moods/mood_happy.png';
        break;
      case "Fair":
        imagePath = 'assets/images/moods/mood_calm.png';
        break;
      default:
        imagePath = 'assets/images/moods/mood_tired.png';
    }

    return Column(
      children: [
        Image.asset(
          imagePath,
          height: 100,
        ),

        const SizedBox(height: 8),

        Text(
          "คะแนนรวม $score / 220 คะแนน",
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w700
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _getResultThai(result),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w700
          ),
        ),
      ],
    );
  }

  /// Main result card containing explanation text and optional chat button
  Widget _resultCard(BuildContext context, String result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getDescription(result),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500
            ),
          ),

          const SizedBox(height: 12),

          /// Chat button available only for normal users
          if (!isAdminView)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PsychiatristChatPage(),
                  ),
                );
              },
              child: const Text(
                "พูดคุยกับจิตแพทย์",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Source/credit information of the assessment tool
  Widget _creditSection() {
    return Text(
      "แบบทดสอบนี้อ้างอิงจาก"
      "แบบทดสอบดัชนีชี้วัดสุขภาพจิตคนไทยฉบับสมบูรณ์ 55 ข้อ ปีพ.ศ.2550"
      "\n[Thai Mental Health Indicator Version 2077 = TMHI-55]"
      "\nกรมสุขภาพจิต กระทรวงสาธารณสุข",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 13,
        fontWeight: FontWeight.w600
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Button to retake the assessment
  Widget _retakeAssessmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PsychiatristSelfAssessmentPage(
                isViewOnly: false,
              ),
            ),
          );
        },
        child: const Text(
          "เริ่มทำแบบประเมินใหม่อีกครั้ง",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Button to view assessment history
  Widget _historyAssessmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.teal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PsychiatristSelfAssessmentPage(
                isViewOnly: true,
                userId: userId,
              ),
            ),
          );
        },
        child: const Text(
          "ดูประวัติการทำแบบประเมิน",
          style: TextStyle(
            color: Colors.teal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
/*
* File: psychiatrist_self_assessment_result.dart
* Description: Displays mental health self-assessment results by retrieving data from Firebase Firestore. Shows score interpretation, feedback messages, and provides navigation to chat with a psychiatrist and assessment history.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_chat_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';

class PsychiatristSelfAssessmentResultPage extends StatelessWidget {
  final String? userId;
  final bool isAdminView;

  const PsychiatristSelfAssessmentResultPage({
    super.key,
    this.userId,
    this.isAdminView = false,
  });

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
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = isAdminView ? userId : currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('self_assessment_results')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("ไม่พบข้อมูลผู้ใช้")
          );
        }

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

                _resultHeader(score, result),

                const SizedBox(height: 20),

                _resultCard(context, result),

                const SizedBox(height: 20),

                // _criteriaSection(),

                _creditSection(),

                const Spacer(),

                if (!isAdminView) ...[
                  _retakeAssessmentButton(context),
                  const SizedBox(height: 12),
                ],

                _historyAssessmentButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

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

  // Widget _criteriaSection() {
  //   return const Column(
  //     children: [
  //       Text("เกณฑ์ปกติที่กำหนด", 
  //       style: TextStyle(
  //         color: Colors.grey,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold
  //       )),

  //       SizedBox(height: 5),

  //       Text(
  //         "คะแนน 0-157  มีสุขภาพจิตต่ำกว่าคนทั่วไป (Poor)",
  //         style: TextStyle(
  //           color: Colors.grey,
  //           fontSize: 12,
  //         )
  //       ),

  //       Text(
  //         "คะแนน 158-178 มีสุขภาพจิตเท่ากับคนทั่วไป (Fair)",
  //         style: TextStyle(
  //           color: Colors.grey,
  //           fontSize: 12,
  //         )
  //       ),

  //       Text(
  //         "คะแนนมากกว่า 178 มีสุขภาพจิตดีกว่าคนทั่วไป (Good)",
  //         style: TextStyle(
  //           color: Colors.grey,
  //           fontSize: 12,
  //         )
  //       ),
  //     ],
  //   );
  // }

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
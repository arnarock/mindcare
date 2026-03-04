import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_chat_page.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';

class PsychiatristSelfAssessmentResultPage extends StatelessWidget {
  const PsychiatristSelfAssessmentResultPage({super.key});

  String _getEmoji(String result) {
    switch (result) {
      case "Good":
        return "😊";
      case "Fair":
        return "🙂";
      default:
        return "😟";
    }
  }

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
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับดี\n"
            "สามารถรับมือกับปัญหาในชีวิตประจำวันได้อย่างเหมาะสม\n"
            "ควรรักษาพฤติกรรมด้านบวกและดูแลสุขภาพจิตอย่างสม่ำเสมอ\n"
            "การพักผ่อนและทำกิจกรรมที่ชอบจะช่วยเสริมสุขภาวะทางใจให้ดียิ่งขึ้น";
      case "Fair":
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับปานกลาง\n"
            "อาจมีความเครียดหรือความกังวลในบางช่วงเวลา\n"
            "ควรดูแลตนเองด้วยการพักผ่อนให้เพียงพอและผ่อนคลายความเครียด\n"
            "หากรู้สึกไม่สบายใจต่อเนื่องควรปรึกษาผู้เชี่ยวชาญ";
      default:
        return "จากผลการประเมินพบว่าท่านมีสุขภาพจิตอยู่ในระดับต่ำกว่าคนทั่วไป\n"
            "อาจกำลังเผชิญกับความเครียดหรือความทุกข์ใจในชีวิตประจำวัน\n"
            "ควรได้รับการดูแลด้านจิตใจอย่างเหมาะสม\n"
            "การพูดคุยกับผู้เชี่ยวชาญหรือคนที่ไว้ใจได้จะช่วยให้รู้สึกดีขึ้น\n"
            "ท่านไม่จำเป็นต้องเผชิญปัญหาเพียงลำพัง";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('self_assessment_results')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
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
                _criteriaSection(),
                const Spacer(),
                _retakeAssessmentButton(context),
                const SizedBox(height: 12),
                _historyAssessmentButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resultHeader(int score, String result) {
    return Column(
      children: [
        Text(_getEmoji(result), style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 8),
        Text(
          "คุณได้คะแนนรวม $score / 220 คะแนน",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _getResultThai(result),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600
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
              fontSize: 16, 
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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

  Widget _criteriaSection() {
    return const Column(
      children: [
        Text("เกณฑ์ปกติที่กำหนด", 
        style: TextStyle(
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: 8),
        Text("คะแนน 0-157  มีสุขภาพจิตต่ำกว่าคนทั่วไป (Poor)"),
        Text("คะแนน 158-178 มีสุขภาพจิตเท่ากับคนทั่วไป (Fair)"),
        Text("คะแนนมากกว่า 178 มีสุขภาพจิตดีกว่าคนทั่วไป (Good)"),
      ],
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
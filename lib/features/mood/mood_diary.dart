import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodDiaryPage extends StatelessWidget {
  final DateTime selectedDate;

  const MoodDiaryPage({
    super.key,
    required this.selectedDate,
  });

  String get formattedDate {
    return "${selectedDate.year}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Diary"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('moods')
            .doc(formattedDate)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("No mood recorded"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final emoji = data['emoji'] ?? '';
          final mood = data['mood'] ?? '';
          final note = data['note'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // วันที่
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // Emoji ใหญ่ ๆ
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 60),
                ),

                const SizedBox(height: 20),

                // Mood text
                Text(
                  mood,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Note
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      note,
                      style:
                          const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
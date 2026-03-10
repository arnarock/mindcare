import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/core/constants/mood_images.dart';

class MoodDiaryPage extends StatelessWidget {
  final DateTime selectedDate;

  const MoodDiaryPage({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    final dateKey = DateFormat("yyyy-MM-dd").format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Diary"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('moods')
            .doc(dateKey)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text("No mood recorded"),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final entries = List.from(data["entries"]);

          final avgMood = data["averageMood"];
          final avgScore = data["averageScore"];

          final scores = entries.map((e) => e["score"] ?? 0).toList();
          final formulaLeft = scores.join(" + ");

          double total = 0;
          for (var s in scores) {
            total += s;
          }

          final average = scores.isEmpty ? 0 : total / scores.length;

          final formulaText =
              "($formulaLeft) / ${scores.length} = ${average.toStringAsFixed(2)}";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Arna Test",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        MoodImages.map[avgMood] ?? "",
                        height: 70,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        avgMood,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Score: ${avgScore.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formulaText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Today ${entries.length} Mood",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "ALL Mood Today",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...entries.map((entry) {
                final mood = entry["mood"] ?? "";
                final note = entry["note"] ?? "";
                final score = entry["score"] ?? 0;

                String timeText = "";
                if (entry["createdAt"] != null) {
                final Timestamp ts = entry["createdAt"];
                final DateTime dt = ts.toDate();
                timeText = DateFormat("HH:mm").format(dt);
              }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          MoodImages.map[mood] ?? "",
                          height: 40,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    mood,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    "Score $score",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                note,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
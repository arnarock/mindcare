/*
* File: mood_diary.dart
* Description: Mood diary page for recording, viewing, editing, and deleting daily mood entries, with automatic calculation of average mood and navigation between dates.
*
* Authors: 
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:mindcare/core/constants/mood_images.dart';
import 'package:mindcare/core/constants/mood_calculator.dart';
import 'package:mindcare/features/mood/mood_add.dart';

/// Page for viewing and managing mood diary entries for a specific date.
///
/// Responsibilities:
/// - Display daily mood summary including average mood and total entries
/// - List all mood entries with time, note, and actions
/// - Allow navigation between dates and date selection
/// - Support editing and deleting mood entries
/// - Recalculate and persist updated mood data
class MoodDiaryPage extends StatefulWidget {
  final DateTime selectedDate;

  const MoodDiaryPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<MoodDiaryPage> createState() => _MoodDiaryPageState();
}

/// State that handles current date navigation,
/// data retrieval, and entry management.
class _MoodDiaryPageState extends State<MoodDiaryPage> {

  /// Currently displayed date in the diary
  late DateTime currentDate;

  /// Checks whether a given date is today
  bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;
  }

  @override
  void initState() {
    super.initState();

    /// Initialize with selected date from calendar
    currentDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {

    /// Get logged-in user
    final user = FirebaseAuth.instance.currentUser;

    /// Format display date
    final displayDate =
      "${currentDate.day} / ${currentDate.month} / ${currentDate.year}";

    /// Firestore document key for this date
    final dateKey = DateFormat("yyyy-MM-dd").format(currentDate);

    /// If not logged in
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mood Diary",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),

      /// Listen to real-time mood data for the selected date
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

          /// List of mood entries for that day
          List entries = [];

          /// Average mood label for that day
          String? avgMood;

          /// If document exists, extract data
          if (snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            entries = List.from(data["entries"]);
            avgMood = data["averageMood"];
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              /// Summary card showing average mood and date navigation
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      /// Date navigation row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          /// Previous day button
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: previousDay,
                          ),

                          /// Tap date to open date picker
                          InkWell(
                            onTap: pickDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(
                                displayDate,
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          /// Next day button (hidden if today)
                          isToday(currentDate)
                            ? const SizedBox(width: 48)
                            : IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: nextDay,
                              )
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Average mood icon
                      Image.asset(
                        entries.isEmpty
                          ? 'assets/images/moods/mood_none.png'
                          : MoodImages.map[avgMood] ??
                              'assets/images/moods/mood_none.png',
                        height: 70,
                      ),

                      const SizedBox(height: 8),

                      /// Average mood text or no-data message
                      Text(
                        entries.isEmpty 
                          ? isToday(currentDate) 
                            ? "No mood recorded today" 
                            : "No mood recorded" 
                          : avgMood!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                      ),

                      const SizedBox(height: 6),
                      
                      /// Number of entries recorded
                      Text(
                        isToday(currentDate) 
                          ? "${entries.length} Mood Recorded Today"
                          : "${entries.length} Mood Recorded",
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

              /// Section title if entries exist
              if (!entries.isEmpty) 
                const Text(
                  "ALL Mood Today",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),
              
                /// List of all mood entries
                ...entries.map((entry) {

                  final mood = entry["mood"] ?? "";
                  final note = entry["note"] ?? "";

                  /// Format time from timestamp
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

                          /// Mood icon
                          Image.asset(
                            MoodImages.map[mood] ?? "",
                            height: 40,
                          ),

                          const SizedBox(width: 12),

                          /// Mood details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// Mood name + time
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
                                  ],
                                ),

                                /// Optional note
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    note,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ]
                              ],
                            ),
                          ),

                          /// Edit & Delete buttons
                          Row (
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20
                                ),
                                onPressed: () => editMood(entry),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => showDeleteDialog(entry),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  );
                }
              ).toList(),
            ],
          );
        },
      ),
    );
  }

  /// Navigate to previous day
  void previousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  /// Navigate to next day
  void nextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
  }

  /// Open date picker to select another day
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        currentDate = picked;
      });
    }
  }

  /// Open mood editor for selected entry
  Future<void> editMood(Map entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodAddPage(
          selectedDate: currentDate,
          editEntry: entry,
        ),
      ),
    );
  }

  /// Show confirmation dialog before deleting entry
  Future<void> showDeleteDialog(Map entry) async {
    final mood = entry["mood"] ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const SizedBox(height: 12),

              /// Mood icon preview
              Image.asset(
                MoodImages.map[mood] ?? "",
                height: 60,
              ),

              const SizedBox(height: 12),

              const Text(
                "Delete Mood?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),
            
              Text(
                mood,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Are you sure you want to \ndelete this mood entry?",
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actionsAlignment: MainAxisAlignment.spaceBetween,

          actions: [

            /// Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
              ),
            ),

            /// Confirm delete button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await deleteMood(entry);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete mood entry from Firestore
  /// and recalculate daily average mood
  Future<void> deleteMood(Map entry) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateKey = DateFormat("yyyy-MM-dd").format(currentDate);

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("moods")
        .doc(dateKey);

    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    List entries = List.from(snapshot.data()!["entries"]);

    /// Remove entry by ID
    entries.removeWhere((e) => e["id"] == entry["id"]);

    /// If no entries remain, reset averages
    if (entries.isEmpty) {
      await docRef.update({
        "entries": [],
        "averageMood": null,
        "averageScore": 0,
      });
      return;
    }

    /// Recalculate average mood
    List<String> moods =
        entries.map((e) => e["mood"].toString()).toList();

    final avg = MoodCalculator.calculate(moods);

    await docRef.update({
      "entries": entries,
      "averageMood": avg["averageMood"],
      "averageScore": avg["averageScore"],
      "updatedAt": Timestamp.now(),
    });
  }
}
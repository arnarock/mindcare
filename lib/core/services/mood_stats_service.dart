/*
* File: mood_stats_service.dart
* Description: Provides methods to calculate mood statistics for the current user, including the monthly average mood score and the percentage of days with a “healthy” mood, based on Firestore data.
*
* Responsibilities:
* - Initialize local notification settings for Android devices
* - ขออนุญาตการแจ้งเตือนจากผู้ใช้
* - แสดงการแจ้งเตือนแบบ high-priority สำหรับ Mood Reminder
* - ใช้งาน NotificationService ได้แบบ static ทั่วทั้งแอป
*
* Authors: <Anajak Chuamuangphan 650510692/ zoozoo>
* Course: Mobile App Development
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides statistical calculations related to the user's mood data.
///
/// This service retrieves mood records from Firestore and computes
/// metrics for the current month, such as the percentage of healthy
/// mood days and the average mood score.
///
/// Responsibilities:
/// - Fetch monthly mood entries for the authenticated user
/// - Calculate percentage of healthy mood days
/// - Compute average mood score for the current month
///
/// Notes:
/// - All methods are static and asynchronous
/// - Requires Firebase Authentication and Firestore
/// - Returns 0 when no user is signed in or no data exists
class MoodStatsService {

  /// Calculates the percentage of healthy mood days for the current month.
  ///
  /// A day is considered "healthy" if its average mood score is
  /// greater than or equal to 2.
  ///
  /// Returns a value between 0 and 100 representing the percentage
  /// of healthy days among all recorded mood entries for the month.
  ///
  /// Async behavior:
  /// - Performs Firestore queries over the network
  /// - Execution time depends on connectivity and data size
  ///
  /// Failure conditions:
  /// - Returns 0 if no user is signed in
  /// - Returns 0 if no mood records exist for the month
  static Future<double> getHealthyPercentage() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final now = DateTime.now();

    final start =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-01";

    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final end =
        "${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01";

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
        .where(FieldPath.documentId, isLessThan: end)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    int healthy = 0;

    for (var doc in snapshot.docs) {

      final data = doc.data();

      double score = (data["averageScore"] ?? 0).toDouble();

      if (score >= 2) {
        healthy++;
      }
    }

    return (healthy / snapshot.docs.length) * 100;
  }

  /// Calculates the average mood score for the current month.
  ///
  /// This method aggregates all mood entries recorded in the
  /// current month and computes their mean score.
  ///
  /// Returns the average mood score as a double value.
  ///
  /// Async behavior:
  /// - Performs Firestore queries over the network
  /// - Execution time depends on connectivity and data size
  ///
  /// Failure conditions:
  /// - Returns 0 if no user is signed in
  /// - Returns 0 if no mood records exist for the month
  static Future<double> getAverageMood() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final now = DateTime.now();

    final start =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-01";

    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final end =
        "${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01";

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
        .where(FieldPath.documentId, isLessThan: end)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    double total = 0;

    for (var doc in snapshot.docs) {

      final data = doc.data();

      double score = (data["averageScore"] ?? 0).toDouble();

      total += score;
    }

    return total / snapshot.docs.length;
  }

}
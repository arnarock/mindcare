/*
* File: mood_stats_service.dart
* Description: Provides methods to calculate mood statistics for the current user, including the monthly average mood score and the percentage of days with a “healthy” mood, based on Firestore data.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodStatsService {

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
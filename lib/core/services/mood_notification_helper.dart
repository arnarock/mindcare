/*
* File: mood_notification_helper.dart
* Description: Provides utilities for generating personalized mood-based notifications for users, converting mood scores to descriptive moods, selecting encouraging messages, and sending daily reminders via local notifications.
*
* Authors:
* -  
* - 
* - 
*/
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class MoodNotificationHelper {
  static final Random _random = Random();

  static String scoreToMood(double avg) {
    if (avg >= 4.5) return "Ecstatic";
    if (avg >= 3.5) return "Excited";
    if (avg >= 2) return "Happy";
    if (avg >= 0) return "Calm";
    if (avg >= -1.5) return "Bored";
    if (avg >= -2.5) return "Tired";
    if (avg >= -3.5) return "Worried";
    if (avg >= -4.5) return "Sad";
    return "Stressed";
  }

  static String moodToMessage(String mood) {
    final Map<String, List<String>> messages = {

      "Ecstatic": [
        "ดีใจที่วันนี้คุณมีความสุขมากขนาดนี้นะ ✨ เก็บช่วงเวลาดี ๆ นี้ไว้เป็นพลังให้ตัวเองนะ",
        "พลังดี ๆ ของคุณวันนี้สวยงามมาก ขอให้ความสุขนี้อยู่กับคุณไปทั้งวัน",
        "รอยยิ้มของคุณวันนี้มีความหมายมาก อย่าลืมภูมิใจกับวันที่ดีของตัวเองนะ",
        "บางวันชีวิตก็ให้ของขวัญกับเราแบบนี้ ดีใจด้วยจริง ๆ",
        "วันนี้คุณดูเปล่งประกายมากเลย ขอให้ความสุขนี้เติมพลังให้หัวใจคุณนะ"
      ],

      "Excited": [
        "วันนี้ดูเหมือนหัวใจคุณเต็มไปด้วยพลังนะ ลองใช้มันทำสิ่งที่อยากทำดู",
        "ความตื่นเต้นแบบนี้เป็นสัญญาณของสิ่งดี ๆ ที่กำลังจะเกิดขึ้น",
        "พลังของคุณวันนี้น่าชื่นชมมาก ขอให้วันนี้เป็นวันที่ดีนะ",
        "ดูเหมือนวันนี้คุณพร้อมสำหรับอะไรใหม่ ๆ แล้วนะ",
        "ใช้พลังดี ๆ วันนี้สร้างช่วงเวลาที่ดีให้ตัวเองนะ"
      ],

      "Happy": [
        "ดีใจที่วันนี้คุณมีรอยยิ้ม 😊 ความสุขเล็ก ๆ แบบนี้มีค่ามากจริง ๆ",
        "วันนี้ดูเหมือนหัวใจคุณเบาสบาย ดีใจที่คุณมีวันดี ๆ แบบนี้",
        "เก็บความรู้สึกดี ๆ วันนี้ไว้เป็นกำลังใจให้ตัวเองนะ",
        "บางวันแค่ได้รู้สึกดีแบบนี้ ก็ถือว่าเป็นวันที่ดีมากแล้ว",
        "ขอให้ความสุขเล็ก ๆ วันนี้อยู่กับคุณไปทั้งวันนะ"
      ],

      "Calm": [
        "วันนี้ดูเหมือนหัวใจคุณได้พักสักหน่อย ความสงบแบบนี้มีค่ามากนะ",
        "บางวันเรียบง่ายและสงบแบบนี้ ก็เป็นของขวัญให้ใจเรา",
        "ขอให้วันนี้เป็นวันที่คุณได้อยู่กับตัวเองอย่างสบายใจ",
        "การได้พักใจเงียบ ๆ แบบนี้ ก็เป็นการดูแลตัวเองอย่างหนึ่ง",
        "ลองหายใจลึก ๆ แล้วปล่อยให้ใจสบายไปกับวันนี้นะ"
      ],

      "Bored": [
        "ถ้าวันนี้ดูเงียบ ๆ ก็ไม่เป็นไรนะ บางวันชีวิตก็แค่ต้องการจังหวะช้าลง",
        "ลองหาสิ่งเล็ก ๆ ที่ทำให้ตัวเองยิ้มได้สักอย่างนะ",
        "บางทีความเบื่อก็เป็นช่วงพักของชีวิตเหมือนกัน",
        "วันนี้อาจธรรมดา แต่คุณก็ผ่านมันมาได้ดีนะ",
        "บางวันเรียบง่ายก็โอเคนะ ดูแลตัวเองดี ๆ นะ"
      ],

      "Tired": [
        "ถ้าวันนี้คุณเหนื่อย เราอยากบอกว่าคุณทำดีมากแล้วนะ พักได้เลย",
        "คุณพยายามมามากแล้วจริง ๆ ให้ตัวเองได้พักบ้างนะ",
        "วันนี้อาจหนักไปหน่อย ไม่เป็นไรเลย พักก่อนก็ได้",
        "คุณไม่จำเป็นต้องเก่งตลอดเวลา แค่ดูแลตัวเองก็พอ",
        "เหนื่อยวันนี้ไม่เป็นไรนะ พรุ่งนี้ค่อยเริ่มใหม่ได้เสมอ"
      ],

      "Worried": [
        "ถ้าวันนี้คุณกังวล ลองหายใจลึก ๆ สักครั้งนะ ทุกอย่างค่อย ๆ ดีขึ้นได้",
        "ไม่จำเป็นต้องแก้ทุกอย่างในวันนี้ ค่อย ๆ ไปทีละก้าวก็พอ",
        "คุณกำลังพยายามอยู่ และนั่นสำคัญมากจริง ๆ",
        "บางเรื่องต้องใช้เวลา อย่าเพิ่งกดดันตัวเองนะ",
        "คุณไม่ได้อยู่คนเดียว ค่อย ๆ ผ่านวันนี้ไปด้วยกันนะ"
      ],

      "Sad": [
        "ถ้าวันนี้คุณรู้สึกเศร้า มันไม่เป็นไรเลยนะ ความรู้สึกของคุณมีความหมายเสมอ",
        "บางวันหัวใจก็อาจหนักหน่อย แต่คุณไม่ได้อยู่คนเดียว",
        "ให้เวลาหัวใจได้พักนะ วันพรุ่งนี้อาจค่อย ๆ ดีขึ้น",
        "คุณไม่จำเป็นต้องเข้มแข็งตลอดเวลา แค่ดูแลตัวเองก็พอ",
        "แม้วันนี้จะยาก แต่คุณก็ยังผ่านมาได้ และนั่นเก่งมากแล้ว"
      ],

      "Stressed": [
        "ถ้าวันนี้คุณเครียด ลองหยุดพักสักครู่ หายใจลึก ๆ นะ",
        "ค่อย ๆ ทำทีละอย่างก็พอ ไม่ต้องรีบเกินไป",
        "คุณไม่จำเป็นต้องแบกรับทุกอย่างคนเดียว",
        "คุณกำลังพยายามมากอยู่ และนั่นมีค่ามากจริง ๆ",
        "อย่าลืมให้ความเมตตากับตัวเองเหมือนที่คุณให้คนอื่นนะ"
      ],
    };

    final moodMessages = messages[mood];

    if (moodMessages == null || moodMessages.isEmpty) {
      return "วันนี้เป็นยังไงบ้าง ลองแวะมาบันทึกความรู้สึกของคุณดูนะ";
    }

    return moodMessages[_random.nextInt(moodMessages.length)];
  }

  static Future<void> sendTodayMoodNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    final dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .doc(dateKey)
        .get();

    if (!doc.exists) {

      await NotificationService.show(
        "MindCare+",
        "วันนี้เป็นยังไงบ้าง ลองแวะมาบันทึกอารมณ์ของคุณสักนิดนะ",
      );

      return;
    }

    final data = doc.data();

    double avg = (data?["averageScore"] ?? 0).toDouble();

    String mood = scoreToMood(avg);

    String message = moodToMessage(mood);

    await NotificationService.show(
      "MindCare+",
      message,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class MoodNotificationHelper {

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

    switch (mood) {

      case "Ecstatic":
        return "วันนี้ดูเหมือนจะเป็นวันที่ยอดเยี่ยมมาก 😊";

      case "Excited":
        return "พลังของคุณวันนี้ดีมาก เก็บโมเมนต์นี้ไว้นะ";

      case "Happy":
        return "ดีใจที่วันนี้คุณมีความสุข";

      case "Calm":
        return "วันนี้ผ่านไปอย่างสงบ พักผ่อนให้เต็มที่นะ";

      case "Bored":
        return "บางวันอาจน่าเบื่อ แต่พรุ่งนี้อาจมีอะไรใหม่";

      case "Tired":
        return "วันนี้คุณคงเหนื่อย ลองพักผ่อนดูนะ";

      case "Worried":
        return "ไม่เป็นไรนะ ทุกความรู้สึกมีความหมาย";

      case "Sad":
        return "วันนี้อาจหนักไปบ้าง แต่คุณไม่ได้อยู่คนเดียว";

      case "Stressed":
        return "ลองหยุดพักหายใจลึก ๆ คุณทำได้";

      default:
        return "ขอให้คืนนี้พักผ่อนดี ๆ";
    }
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
        "MindCare",
        "วันนี้เป็นยังไงบ้าง อย่าลืมบันทึกอารมณ์ของคุณนะ",
      );

      return;
    }

    final data = doc.data();

    double avg = (data?["averageScore"] ?? 0).toDouble();

    String mood = scoreToMood(avg);

    String message = moodToMessage(mood);

    await NotificationService.show(
      "MindCare",
      message,
    );
  }
}
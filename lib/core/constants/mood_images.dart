/*
* File: mood_images.dart
* Description: Defines a mapping between mood states and their corresponding image asset paths for use in the app’s mood tracking and display features.
*
* Responsibilities:
* - จัดเก็บแผนที่ (Map) ระหว่างชื่ออารมณ์และ path ของรูปภาพ
* - ใช้ใน MoodCalendar, MoodDiary, และ Notifications เพื่อแสดงไอคอนอารมณ์
* - รองรับอารมณ์หลักทั้งหมด เช่น Ecstatic, Excited, Happy, Calm, Bored, Tired, Worried, Sad, Stressed
* - ออกแบบและวาดภาพประกอบอารมณ์ (Mood Icons) สำหรับใช้ในแอป เช่น Ecstatic, Excited, Happy, Calm, Bored, Tired, Worried, Sad, Stressed
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/
class MoodImages {
  static const Map<String, String> map = {
    "None": "assets/images/moods/mood_none.png",
    "Ecstatic": "assets/images/moods/mood_ecstatic.png",
    "Excited": "assets/images/moods/mood_excited.png",
    "Happy": "assets/images/moods/mood_happy.png",
    "Calm": "assets/images/moods/mood_calm.png",
    "Bored": "assets/images/moods/mood_bored.png",
    "Tired": "assets/images/moods/mood_tired.png",
    "Worried": "assets/images/moods/mood_worried.png",
    "Sad": "assets/images/moods/mood_sad.png",
    "Stressed": "assets/images/moods/mood_stressed.png",
  };
}

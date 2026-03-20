/*
* File: mood_calendar.dart
* Description: Interactive mood calendar page that displays a monthly overview of daily mood entries, allows navigation between months and years, and provides quick access to add or view detailed mood diary entries for each day.
*
* Responsibilities:
* - แสดงภาพรวมรายเดือนของอารมณ์ผู้ใช้ในแต่ละวัน
* - เลื่อนดูเดือนต่าง ๆ และเลือกปี
* - แสดงไอคอนอารมณ์ของแต่ละวัน และเน้นวันที่ปัจจุบัน
* - แตะวันเพื่อดู Mood Diary รายวัน (ถ้ามีข้อมูล)
* - ปุ่มเพิ่ม Mood สำหรับวันที่ปัจจุบัน
* - ใช้ StreamBuilder ดึงข้อมูล Mood จาก Firestore แบบ real-time
*
* Authors: <Anajak Chuamuangphan / zoozoo>
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/layout/app_layout.dart';
import 'package:mindcare/core/constants/mood_images.dart';
import 'package:mindcare/features/mood/mood_add.dart';
import 'package:mindcare/features/mood/mood_diary.dart';

class MoodCalendarPage extends StatefulWidget {
  const MoodCalendarPage({super.key});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  late PageController _pageController;
  late DateTime currentMonth;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    _pageController = PageController(
      initialPage: DateTime.now().month - 1,
    );
  }

  DateTime getMonth(int index) {
    return DateTime(selectedYear, index + 1);
  }

  bool canAddMood() {
    final now = DateTime.now();
    return currentMonth.year == now.year && currentMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    return AppLayout(
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: 12,
            onPageChanged: (index) {
              setState(() {
                currentMonth = getMonth(index);
              });
            },
            itemBuilder: (context, index) {
              final monthDate = getMonth(index);
              return _buildMonthView(user.uid, monthDate);
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: canAddMood()
                    ? () async {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MoodAddPage(selectedDate: today),
                          ),
                        );

                        setState(() {});
                      }
                    : null,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(String uid, DateTime monthDate) {
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final nextMonth = DateTime(monthDate.year, monthDate.month + 1, 1);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('moods')
          .where(FieldPath.documentId,
              isGreaterThanOrEqualTo: _dateKey(firstDay))
          .where(FieldPath.documentId, isLessThan: _dateKey(nextMonth))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        Map<int, Map<String, dynamic>> moodMap = {};

        for (var doc in docs) {
          try {
            final date = DateTime.parse(doc.id);
            moodMap[date.day] = doc.data() as Map<String, dynamic>;
          } catch (_) {}
        }

        int daysInMonth =
            DateTime(monthDate.year, monthDate.month + 1, 0).day;

        int startWeekday = firstDay.weekday;

        List<int?> days = [];

        for (int i = 1; i < startWeekday; i++) {
          days.add(null);
        }

        for (int day = 1; day <= daysInMonth; day++) {
          days.add(day);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _monthName(monthDate.month),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                      onSelected: (year) {
                        setState(() {
                          selectedYear = year;
                          currentMonth = DateTime(year, 1);
                        });
                        _pageController.jumpToPage(0);
                      },
                      itemBuilder: (context) => List.generate(
                        5,
                        (i) {
                          int year = 2024 + i;
                          return PopupMenuItem(
                            value: year,
                            child: Text("$year"),
                          );
                        },
                      ),
                      child: Row(
                        children: [
                          Text(
                            "$selectedYear",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Mon"),
                    Text("Tue"),
                    Text("Wed"),
                    Text("Thu"),
                    Text("Fri"),
                    Text("Sat"),
                    Text("Sun"),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: GridView.builder(
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];

                      if (day == null) {
                        return const SizedBox();
                      }

                      final now = DateTime.now();

                      final isToday =
                          day == now.day &&
                          monthDate.month == now.month &&
                          monthDate.year == now.year;

                      final moodData = moodMap[day];
                      final mood = moodData?["averageMood"];
                      final imagePath = MoodImages.map[mood];

                      final date =
                          DateTime(monthDate.year, monthDate.month, day);

                      return GestureDetector(
                        onTap: moodData == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MoodDiaryPage(selectedDate: date),
                                  ),
                                );
                              },
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: isToday
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                             if (imagePath != null)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final size = constraints.maxWidth * 0.90;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Center(
                                      child: Image.asset(
                                        imagePath,
                                        width: size,
                                        height: size,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 4,
                                right: 6,
                                child: Text(
                                  "$day",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}
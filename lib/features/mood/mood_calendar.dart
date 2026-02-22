import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mood_add.dart';
import 'mood_diary.dart';
import 'package:mindcare/core/layout/app_layout.dart';

class MoodCalendarPage extends StatefulWidget {
  const MoodCalendarPage({super.key});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  final PageController _pageController =
      PageController(initialPage: 1000);

  final DateTime baseDate = DateTime.now();

  DateTime getMonth(int pageIndex) {
    return DateTime(
      baseDate.year,
      baseDate.month + (pageIndex - 1000),
    );
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
            itemBuilder: (context, index) {
              final monthDate = getMonth(index);
              return _buildMonthView(user.uid, monthDate);
            },
          ),

          // Floating button (เพราะเราไม่มี Scaffold แล้ว)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoodAddPage(
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
}

  Widget _buildMonthView(String uid, DateTime monthDate) {
    final firstDay =
        DateTime(monthDate.year, monthDate.month, 1);
    final nextMonth =
        DateTime(monthDate.year, monthDate.month + 1, 1);

    final daysInMonth =
        DateTime(monthDate.year, monthDate.month + 1, 0).day;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('moods')
          .where('createdAt', isGreaterThanOrEqualTo: firstDay)
          .where('createdAt', isLessThan: nextMonth)
          .snapshots(),
      builder: (context, snapshot) {
        Map<String, String> moodMap = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data =
                doc.data() as Map<String, dynamic>;
            final timestamp =
                data['createdAt'] as Timestamp;
            final date = timestamp.toDate();
            final key =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

            moodMap[key] = data['emoji'];
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "${_monthName(monthDate.month)} ${monthDate.year}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final key =
                          "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

                      final emoji = moodMap[key];

                      return GestureDetector(
                        onTap: emoji != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MoodDiaryPage(selectedDate: DateTime(monthDate.year, monthDate.month, day)),
                                  ),
                                );
                              }
                            : null,
                        child: Center(
                          child: Text(
                            emoji ?? '',
                            style:
                                const TextStyle(fontSize: 28),
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
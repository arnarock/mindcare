import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/features/mood/mood_add.dart';
import 'package:mindcare/features/mood/mood_diary.dart';
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
  late DateTime currentMonth;

  static const Map<String, String> moodImages = {
    "Ecstatic": "assets/images/moods/mood_ecstatic.png",
    "Happy": "assets/images/moods/mood_happy.png",
    "Calm": "assets/images/moods/mood_calm.png",
    "Bored": "assets/images/moods/mood_bored.png",
    "Tired": "assets/images/moods/mood_tired.png",
    "Worried": "assets/images/moods/mood_worried.png",
  };

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
  }

  DateTime getMonth(int pageIndex) {
    return DateTime(
      baseDate.year,
      baseDate.month + (pageIndex - 1000),
    );
  }

  bool canAddMood() {
    final now = DateTime.now();
    return currentMonth.year == now.year &&
        currentMonth.month == now.month;
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
                        final today = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        );

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MoodAddPage(
                              selectedDate: today,
                            ),
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
    final firstDay =
        DateTime(monthDate.year, monthDate.month, 1);
    final nextMonth =
        DateTime(monthDate.year, monthDate.month + 1, 1);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('moods')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final date = DateTime.parse(doc.id);
          return date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                 date.isBefore(nextMonth);
        }).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Text(
                  "${_monthName(monthDate.month)} ${monthDate.year}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                if (docs.isEmpty)
                  const Text(
                    "No moods this month",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                if (docs.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final avgMood = data["averageMood"] ?? "Calm";

                            final imagePath =
                                moodImages[avgMood] ??
                                "assets/images/moods/mood_calm.png";

                            final date = DateTime.parse(doc.id);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                      MoodDiaryPage(selectedDate: date),
                                  ),
                                );
                              },
                              child: Image.asset(
                                imagePath,
                                width: 50,
                                height: 50,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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
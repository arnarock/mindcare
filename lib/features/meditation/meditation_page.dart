/*
* File: register_screen.dart
* Description: User registration screen for the MindCare app that allows new users to create an account with first name, last name, phone number, email, and password. It includes input validation, password visibility toggle, phone number formatting, Firebase Authentication for account creation, email verification, and storing user data in Firestore.
*
* Responsibilities:
* - แสดงหน้าการทำสมาธิพร้อมแอนิเมชันการหายใจ
* - อนุญาตให้ผู้ใช้ตั้งค่าระยะเวลาการทำสมาธิได้
* - จัดการตัวจับเวลา (Timer) สำหรับการนับถอยหลังของเซสชัน
* - ควบคุมการเริ่ม หยุดชั่วคราว และรีเซ็ตการทำสมาธิ
* - แสดงแอนิเมชันการหายใจระหว่างการทำสมาธิ
* - แสดงหน้าต่างแจ้งเตือนเมื่อทำสมาธิครบตามเวลาที่กำหนด
* - จัดการสถานะการทำงานและการโต้ตอบของผู้ใช้ในหน้าการทำสมาธิ
*
* Authors: 
* - Nanticha Muangpun 650510623
* - Atitaya Khangtan 650510650
* Course: Mobile App Development
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mindcare/core/layout/app_layout.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with SingleTickerProviderStateMixin {

  /// ค่าเริ่มต้น 5 นาที
  int remainingSeconds = 300;
  int sessionSeconds = 300;

  Timer? timer;
  bool isRunning = false;
  bool hasStarted = false;

  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    /// breathing animation
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathAnimation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// --------------------------
  /// เลือกเวลา
  /// --------------------------
  Future<void> _showSetTime() async {
    final selectedMinutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const SetTimeSheet(),
    );

    if (selectedMinutes != null) {
      timer?.cancel();

      setState(() {
        remainingSeconds = selectedMinutes * 60;
        sessionSeconds = selectedMinutes * 60;
        isRunning = false;
        hasStarted = false;
      });
    }
  }

  /// --------------------------
  /// เริ่มจับเวลา
  /// --------------------------
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        _breathController.stop();

        setState(() {
          isRunning = false;
        });

        _showCompletionDialog();
      }
    });
  }

  /// START / PAUSE
  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      _breathController.stop();
    } else {
      startTimer();
      _breathController.repeat(reverse: true);
      hasStarted = true;
    }

    setState(() {
      isRunning = !isRunning;
    });
  }

  /// RESET
  void resetTimer() {
    timer?.cancel();
    _breathController.stop();

    setState(() {
      remainingSeconds = sessionSeconds;
      isRunning = false;
      hasStarted = false;
    });
  }

  /// POP-UP เมื่อครบเวลา
  void _showCompletionDialog() {
    final completedMinutes = sessionSeconds ~/ 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "✔ Well done.",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "You meditated for $completedMinutes minutes.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Meditation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.timer, color: Colors.teal),
                  onPressed: _showSetTime,
                )
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Time for Meditation...",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 60),

            /// Breathing Circle
            ScaleTransition(
              scale: _breathAnimation,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Breathe",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            /// Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: toggleTimer,
                  child: Text(
                    isRunning ? "PAUSE" : "START",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),

                if (hasStarted) ...[
                  const SizedBox(width: 16),

                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: resetTimer,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
/// หน้าเลือกเวลา
/// ------------------------------
class SetTimeSheet extends StatefulWidget {
  const SetTimeSheet({super.key});

  @override
  State<SetTimeSheet> createState() => _SetTimeSheetState();
}

class _SetTimeSheetState extends State<SetTimeSheet> {

  int selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [

          const SizedBox(height: 20),

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Set Time",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 60,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMinutes = index + 1;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final minute = index + 1;
                  return Center(
                    child: Text(
                      "$minute min",
                      style: TextStyle(
                        fontSize: 24,
                        color: selectedMinutes == minute
                            ? Colors.teal
                            : Colors.grey,
                      ),
                    ),
                  );
                },
                childCount: 60,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, selectedMinutes);
              },
              child: const Text(
                "START",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
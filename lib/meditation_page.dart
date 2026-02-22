import 'dart:async';
import 'package:flutter/material.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {

  int remainingSeconds = 300;
  int sessionSeconds = 300;

  Timer? timer;
  bool isRunning = false;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();

    // เปิดหน้าเลือกเวลาเมื่อเข้าหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSetTime();
    });
  }

  /// --------------------------
  /// เลือกเวลา
  /// --------------------------
  void _showSetTime() async {
    final selectedMinutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) => const SetTimeSheet(),
    );

    if (selectedMinutes != null) {
      setState(() {
        remainingSeconds = selectedMinutes * 60;
        sessionSeconds = selectedMinutes * 60;
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

        setState(() {
          isRunning = false;
        });

        _showCompletionDialog(); // ✅ เด้ง popup ตอนครบเวลา
      }
    });
  }

  /// START / PAUSE
  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
    } else {
      startTimer();
      hasStarted = true;
    }

    setState(() {
      isRunning = !isRunning;
    });
  }

  /// RESET
  void resetTimer() {
    timer?.cancel();

    setState(() {
      remainingSeconds = sessionSeconds;
      isRunning = false;
      hasStarted = false;
    });

    _showSetTime();
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

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Meditation"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _showSetTime,
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Time for Meditation...",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 40),

            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

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
              child: const Text("START"),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
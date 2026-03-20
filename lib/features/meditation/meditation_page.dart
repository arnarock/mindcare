/*
* File: meditation_page.dart
* Description: Meditation screen that guides users through a timed breathing session with animation, countdown timer, and user controls.
*
* Authors: 
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mindcare/core/layout/app_layout.dart';

/// Meditation screen that guides users through a timed
/// breathing meditation session.
///
/// Responsibilities:
/// - Display breathing meditation UI with animation
/// - Allow users to configure session duration
/// - Manage countdown timer for meditation sessions
/// - Control start, pause, and reset actions
/// - Animate breathing pattern during session
/// - Show completion dialog when session ends
/// - Handle user interaction and session state
class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

/// State class that manages timer logic, animation,
/// and user interactions during the meditation session.
class _MeditationPageState extends State<MeditationPage>
    with SingleTickerProviderStateMixin {

  /// ค่าเริ่มต้น 5 นาที
  /// Remaining time in seconds.
  int remainingSeconds = 300;

  /// Total session duration in seconds.
  int sessionSeconds = 300;

  /// Timer for countdown.
  Timer? timer;

  /// Indicates whether the timer is currently running.
  bool isRunning = false;

  /// Indicates whether a session has started at least once.
  bool hasStarted = false;

  /// Animation controller for breathing effect.
  late AnimationController _breathController;

  /// Scale animation used to simulate breathing in/out.
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
  /// Opens bottom sheet for selecting meditation duration.
  Future<void> _showSetTime() async {
    final selectedMinutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const SetTimeSheet(),
    );

    /// Update session time if user selects a value.
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
  /// Starts countdown timer that updates every second.
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

        /// Show completion dialog when session ends.
        _showCompletionDialog();
      }
    });
  }

  /// START / PAUSE
  /// Toggles between starting and pausing the session.
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
  /// Resets timer and animation to initial state.
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
  /// Displays dialog indicating session completion.
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
    /// Cancel timer and dispose animation to prevent leaks.
    timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the meditation session UI.
    return AppLayout(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            /// Header with page title and time settings button.
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

            /// Breathing Circle animation.
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

            /// Control buttons (Start/Pause and Reset).
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

                /// Reset button shown only after session starts.
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

/// Bottom sheet for selecting meditation duration in minutes.
class SetTimeSheet extends StatefulWidget {
  const SetTimeSheet({super.key});

  @override
  State<SetTimeSheet> createState() => _SetTimeSheetState();
}

/// State class for time selection sheet.
class _SetTimeSheetState extends State<SetTimeSheet> {

  /// Currently selected duration in minutes.
  int selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {

    /// Builds scrollable wheel picker for time selection.
    return SizedBox(
      height: 400,
      child: Column(
        children: [

          const SizedBox(height: 20),

          /// Drag indicator.
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

          /// Wheel selector for minutes (1–60).
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

          /// Confirm button returning selected time.
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
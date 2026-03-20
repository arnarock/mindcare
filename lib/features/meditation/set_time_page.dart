/*
* File: register_screen.dart
* Description: User registration screen for the MindCare app that allows new users to create an account with first name, last name, phone number, email, and password. It includes input validation, password visibility toggle, phone number formatting, Firebase Authentication for account creation, email verification, and storing user data in Firestore.
*
* Responsibilities:
* - แสดงหน้าสำหรับตั้งค่าระยะเวลาในการจับเวลา (หน่วยเป็นนาที)
* - ให้ผู้ใช้เลือกเวลาผ่านตัวเลือกแบบวงล้อเลื่อน (Scroll Wheel Picker)
* - แสดงค่าที่เลือกแบบเรียลไทม์ขณะเลื่อน
* - ส่งค่าระยะเวลาที่ผู้ใช้เลือกกลับไปยังหน้าก่อนหน้า
* - เริ่มการทำงานของตัวจับเวลาเมื่อผู้ใช้กดปุ่ม START
* - จัดการอินเทอร์เฟซและการโต้ตอบของผู้ใช้ในหน้าตั้งเวลา
*
* Authors: 
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';

/// A page that allows the user to select meditation time
/// using a scrollable wheel picker.
///
/// Features:
/// - Minute selection from 1 to 60 minutes
/// - Highlighted selected value
/// - Returns selected time to previous screen
/// - Used before starting a meditation session
class SetTimePage extends StatefulWidget {
  const SetTimePage({super.key});

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

/// State class that manages the selected time
/// and updates the UI when the selection changes.
class _SetTimePageState extends State<SetTimePage> {

  /// Stores the currently selected duration in minutes.
  /// Default value is 5 minutes.
  int selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {

    /// Builds the time selection interface.
    return Scaffold(
      backgroundColor: Colors.white,

      /// Ensures content stays within safe display areas.
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// Page title
            const Text(
              "Set Time",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ⏳ Scroll Time Picker

            /// Scrollable wheel picker for selecting minutes.
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 60,

                /// Controls 3D visual effect of the wheel.
                perspective: 0.003,
                diameterRatio: 1.2,

                /// Updates selected value when user scrolls.
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedMinutes = index + 1;
                  });
                },

                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Center(
                      child: Text(
                        "${index + 1} min",

                        /// Highlights the selected minute.
                        style: TextStyle(
                          fontSize: 24,
                          color: selectedMinutes == index + 1
                              ? Colors.teal
                              : Colors.grey,
                        ),
                      ),
                    );
                  },

                  /// Total selectable values (1–60 minutes).
                  childCount: 60,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Start button that confirms selection
            /// and returns the value to the previous page.
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

                  /// Returns selected minutes to previous screen.
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
      ),
    );
  }
}
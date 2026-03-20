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

class SetTimePage extends StatefulWidget {
  const SetTimePage({super.key});

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

class _SetTimePageState extends State<SetTimePage> {
  int selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Set Time",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ⏳ Scroll Time Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 60,
                perspective: 0.003,
                diameterRatio: 1.2,
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
                        style: TextStyle(
                          fontSize: 24,
                          color: selectedMinutes == index + 1
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

            const SizedBox(height: 20),

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
      ),
    );
  }
}
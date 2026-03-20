/*
* File: set_time_page.dart
* Description: A screen that allows users to select meditation duration using a scrollable wheel picker and return the selected value to the previous screen.
*
* Authors: 
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';

/// A page that allows the user to select meditation time
/// using a scrollable wheel picker.
///
/// Responsibilities:
/// - Display UI for selecting duration (in minutes)
/// - Allow users to choose time via scroll wheel picker
/// - Update selected value in real time
/// - Return selected duration to the previous screen
/// - Handle user interaction within the time selection page
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
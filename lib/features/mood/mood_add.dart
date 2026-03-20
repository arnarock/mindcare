/*
* File: register_screen.dart
* Description: User registration screen for the MindCare app that allows new users to create an account with first name, last name, phone number, email, and password. It includes input validation, password visibility toggle, phone number formatting, Firebase Authentication for account creation, email verification, and storing user data in Firestore.
*
* Responsibilities:
* - แสดงหน้าสำหรับเลือกอารมณ์ (Mood) ของผู้ใช้ในวันที่เลือก - Nanticha Muangpun 650510623 / zoozoo
* - ให้ผู้ใช้เลือกอารมณ์ผ่านตัวเลือกแบบ Carousel พร้อมภาพอารมณ์ที่สอดคล้องกัน - Nanticha Muangpun 650510623 / zoozoo
* - เพิ่มช่อง Mood diaryให้ผู้ใช้พิมพ์ข้อความบันทึกความรู้สึก (Mood Diary) -Nanticha Muangpun 650510623 / zoozoo
* - อัปเดตค่าที่เลือกตามการโต้ตอบของผู้ใช้ - Nanticha Muangpun 650510623 / zoozoo
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/constants/mood_images.dart';
import 'package:mindcare/core/constants/mood_calculator.dart';

/// A page for adding or editing a mood entry for a specific date.
///
/// Features:
/// - Select mood using a carousel
/// - Write a mood diary note
/// - Save mood data to Firestore
/// - Supports editing existing entries
/// - Calculates average mood for the day
class MoodAddPage extends StatefulWidget {

  /// The date associated with this mood entry.
  final DateTime selectedDate;

  /// Existing entry data when editing (null when adding new).
  final Map? editEntry;

  const MoodAddPage({
    super.key,
    required this.selectedDate,
    this.editEntry
  });

  @override
  State<MoodAddPage> createState() => _MoodAddPageState();
}

/// State class that manages mood selection,
/// diary input, and saving logic.
class _MoodAddPageState extends State<MoodAddPage> {

  /// Controller for the diary text field.
  final TextEditingController noteController = TextEditingController();

  /// List of available moods to choose from.
  final List<String> moods = [
    "Ecstatic",
    "Excited",
    "Happy",
    "Calm",
    "Bored",
    "Tired",
    "Worried",
    "Sad",
    "Stressed",
  ];

  /// Currently selected mood.
  String selectedMood = '';

  @override
  void initState() {
    super.initState();

    /// If editing, load existing mood and note.
    if (widget.editEntry != null) {
      selectedMood = widget.editEntry!["mood"];
      noteController.text = widget.editEntry!["note"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Formats selected date for display.
    final displayDate =
        "${widget.selectedDate.day} / ${widget.selectedDate.month} / ${widget.selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editEntry == null 
            ? 'Add Mood' 
            : 'Edit Mood',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),

      /// Main content area for mood selection and diary.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Displays selected date.
            Text(
              displayDate,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// Prompt asking how the user feels.
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            /// Mood selection carousel widget.
            MoodCarousel(
              moods: moods,
              initialMood: selectedMood,
              onChanged: (mood) {
                setState(() {
                  selectedMood = mood;
                });
              },
            ),

            const SizedBox(height: 16),

            /// Diary section title.
            const Text(
              'Mood Diary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// Text field for writing feelings or notes.
            Expanded(
              child: TextField(
                controller: noteController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Write your feelings here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),            

            const SizedBox(height: 16),

            /// Button to save mood entry.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  side: const BorderSide(
                    color: Colors.teal,
                    width: 2,
                  ),
                ),
                onPressed: saveMood,
                child: const Text(
                  'Save Mood',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Saves the mood entry to Firestore.
  ///
  /// Behavior:
  /// - Validates mood selection
  /// - Creates or updates daily mood document
  /// - Stores diary note
  /// - Calculates average mood score
  /// - Supports editing existing entries
  Future<void> saveMood() async {

    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select mood")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    /// Generates date key (yyyy-MM-dd).
    final dateKey = DateFormat("yyyy-MM-dd").format(widget.selectedDate);

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("moods")
        .doc(dateKey);

    final snapshot = await docRef.get();

    List entries = [];

    /// Load existing entries if document exists.
    if (snapshot.exists) {
      entries = List.from(snapshot.data()!["entries"]);
    }

    /// Update existing entry when editing.
    if (widget.editEntry != null) {
      final index =
          entries.indexWhere((e) => e["id"] == widget.editEntry!["id"]);
      if (index != -1) {
        entries[index] = {
          ...widget.editEntry!,
          "mood": selectedMood,
          "score": MoodCalculator.moodScore[selectedMood],
          "note": noteController.text.trim(),
        };
      }
    } else {

      /// Create new entry.
      final entry = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "mood": selectedMood,
        "score": MoodCalculator.moodScore[selectedMood],
        "note": noteController.text.trim(),
        "createdAt": Timestamp.now(),
      };
      entries.add(entry);
    }

    /// Calculate daily averages.
    List<String> moodsList =
        entries.map((e) => e["mood"].toString()).toList();

    final avg = MoodCalculator.calculate(moodsList);

    /// Create or update Firestore document.
    if (!snapshot.exists) {
      await docRef.set({
        "averageMood": avg["averageMood"],
        "averageScore": avg["averageScore"],
        "entries": entries,
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
      });
    } else {
      await docRef.update({
        "averageMood": avg["averageMood"],
        "averageScore": avg["averageScore"],
        "entries": entries,
        "updatedAt": Timestamp.now(),
      });
    }

    if (!mounted) return;

    /// Close page after saving.
    Navigator.pop(context);
  }
}

/// A carousel widget for selecting moods visually.
///
/// Features:
/// - Horizontal swipe navigation
/// - Highlight selected mood
/// - Animated scaling and opacity
/// - Optional initial mood selection
class MoodCarousel extends StatefulWidget {

  /// List of moods to display.
  final List<String> moods;

  /// Callback when mood changes.
  final Function(String mood) onChanged;

  /// Initial mood when editing.
  final String? initialMood;

  const MoodCarousel({
    super.key,
    required this.moods,
    required this.onChanged,
    this.initialMood
  });

  @override
  State<MoodCarousel> createState() => _MoodCarouselState();
}

/// State that controls carousel behavior and animations.
class _MoodCarouselState extends State<MoodCarousel> {

  late PageController _pageController;

  /// Currently selected mood index.
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();

    /// Set initial index if editing existing mood.
    if (widget.initialMood != null) {
      final index = widget.moods.indexOf(widget.initialMood!);
      if (index != -1) {
        currentIndex = index;
      }
    }

    _pageController = PageController(
      initialPage: currentIndex,
      viewportFraction: 0.35,
    );

    /// Notify parent of initial selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(widget.moods[currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {

    /// Builds carousel UI with navigation arrows.
    return Center(  
      child: SizedBox(
        height: 120,
        child: Row(
          children: [

            /// Left navigation arrow
            SizedBox(
              width: 30,
              child: currentIndex > 0
                  ? Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 28,
                        ),
                        onPressed: () {
                          _pageController.animateToPage(
                            currentIndex - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ),

            /// Mood pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.moods.length,

                /// Update selection on page change.
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  widget.onChanged(widget.moods[index]);
                },

                /// Builds each mood item.
                itemBuilder: (context, index) {
                  final mood = widget.moods[index];
                  final isSelected = index == currentIndex;

                  return AnimatedScale(
                    scale: isSelected ? 1.15 : 0.85,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,

                    child: AnimatedOpacity(
                      opacity: isSelected ? 1 : 0.5,
                      duration: const Duration(milliseconds: 250),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          /// Mood icon
                          Image.asset(
                            MoodImages.map[mood]!,
                            height: isSelected ? 72 : 52,
                          ),

                          const SizedBox(height: 6),

                          /// Mood label
                          Text(
                            mood,
                            style: TextStyle(
                              fontSize: isSelected ? 16 : 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            /// Right navigation arrow
            SizedBox(
              width: 30,
              child: currentIndex < widget.moods.length - 1
                  ? Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.chevron_right,
                          size: 28,
                        ),
                        onPressed: () {
                          _pageController.animateToPage(
                            currentIndex + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            )
          ]
        )
      )
    );
  }
}

/// A reusable save button component.
///
/// Can be enabled or disabled depending on form state.
class SaveButton extends StatelessWidget {

  /// Whether the button is clickable.
  final bool enabled;

  /// Action when pressed.
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    /// Builds button UI.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: const Text("Save Mood"),
      ),
    );
  }
}
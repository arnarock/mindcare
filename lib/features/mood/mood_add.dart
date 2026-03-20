/*
* File: mood_add.dart
* Description: Page for adding or editing daily mood entries, allowing users to select a mood from a carousel, write notes, and save the entry to their mood diary with automatic calculation of average mood scores.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/constants/mood_images.dart';
import 'package:mindcare/core/constants/mood_calculator.dart';

class MoodAddPage extends StatefulWidget {
  final DateTime selectedDate;
  final Map? editEntry;

  const MoodAddPage({
    super.key,
    required this.selectedDate,
    this.editEntry
  });

  @override
  State<MoodAddPage> createState() => _MoodAddPageState();
}

class _MoodAddPageState extends State<MoodAddPage> {
  final TextEditingController noteController = TextEditingController();

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

  String selectedMood = '';

  @override
  void initState() {
    super.initState();

    if (widget.editEntry != null) {
      selectedMood = widget.editEntry!["mood"];
      noteController.text = widget.editEntry!["note"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayDate,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),
            
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
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

            const Text(
              'Mood Diary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

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

  Future<void> saveMood() async {
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select mood")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateKey = DateFormat("yyyy-MM-dd").format(widget.selectedDate);

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("moods")
        .doc(dateKey);

    final snapshot = await docRef.get();

    List entries = [];

    if (snapshot.exists) {
      entries = List.from(snapshot.data()!["entries"]);
    }

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
      final entry = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "mood": selectedMood,
        "score": MoodCalculator.moodScore[selectedMood],
        "note": noteController.text.trim(),
        "createdAt": Timestamp.now(),
      };
      entries.add(entry);
    }

    List<String> moodsList =
        entries.map((e) => e["mood"].toString()).toList();

    final avg = MoodCalculator.calculate(moodsList);

    if (!snapshot.exists) {
      // create new document
      await docRef.set({
        "averageMood": avg["averageMood"],
        "averageScore": avg["averageScore"],
        "entries": entries,
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
      });
    } else {
      // update lastest document
      await docRef.update({
        "averageMood": avg["averageMood"],
        "averageScore": avg["averageScore"],
        "entries": entries,
        "updatedAt": Timestamp.now(),
      });
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class MoodCarousel extends StatefulWidget {
  final List<String> moods;
  final Function(String mood) onChanged;
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

class _MoodCarouselState extends State<MoodCarousel> {
  late PageController _pageController;
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(widget.moods[currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(  
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            // chevron left
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

            // mood carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.moods.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  widget.onChanged(widget.moods[index]);
                },
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
                          Image.asset(
                            MoodImages.map[mood]!,
                            height: isSelected ? 72 : 52,
                          ),

                          const SizedBox(height: 6),

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
            
            // chevron right
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

class SaveButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: const Text("Save Mood"),
      ),
    );
  }
}
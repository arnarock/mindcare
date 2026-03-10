import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/core/constants/mood_images.dart';

class MoodAddPage extends StatefulWidget {
  final DateTime selectedDate;

  const MoodAddPage({
    super.key,
    required this.selectedDate,
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
  Widget build(BuildContext context) {
    final displayDate =
        "${widget.selectedDate.day} / ${widget.selectedDate.month} / ${widget.selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Mood',
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
              onChanged: (mood) {
                selectedMood = mood;
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

    final entry = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "mood": selectedMood,
      "score": MoodCalculator.moodScore[selectedMood],
      "note": noteController.text.trim(),
      "createdAt": Timestamp.now(),
    };

    entries.add(entry);

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

  const MoodCarousel({
    super.key,
    required this.moods,
    required this.onChanged,
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

    _pageController = PageController(
      initialPage: 2,
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
                onPageChanged: (i) {
                  setState(() {
                    currentIndex = i;
                  });
                  widget.onChanged(widget.moods[i]);
                },
                itemBuilder: (_, i) {
                  final mood = widget.moods[i];
                  final isCenter = i == currentIndex;
    
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isCenter ? 1 : 0.7,
                    child: AnimatedScale(
                      scale: isCenter ? 1.2 : 0.8,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            MoodImages.map[mood]!,
                            height: isCenter ? 70 : 50,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            mood,
                            style: TextStyle(
                              fontSize: isCenter ? 16 : 13,
                              fontWeight: isCenter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          )
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

class MoodCalculator {
  static const Map<String, int> moodScore = {
    "Ecstatic": 5,
    "Excited": 4,
    "Happy": 3,
    "Calm": 1,
    "Bored": -1,
    "Tired": -2,
    "Worried": -3,
    "Sad": -4,
    "Stressed": -5,
  };

  // calculate average score from mood list
  static double calculateAverageScore(List<String> moods) {
    if (moods.isEmpty) return 0;
    int total = 0;
    for (var mood in moods) {
      total += moodScore[mood] ?? 0;
    }
    return total / moods.length;
  }

  // convert score  to mood
  static String scoreToMood(double avg) {
    if (avg >= 4.5) return "Ecstatic";
    if (avg >= 3.5) return "Excited";
    if (avg >= 2) return "Happy";
    if (avg >= 0) return "Calm";
    if (avg >= -1.5) return "Bored";
    if (avg >= -2.5) return "Tired";
    if (avg >= -3.5) return "Worried";
    if (avg >= -4.5) return "Sad";
    return "Stressed";
  }

  // cal score and mood
  static Map<String, dynamic> calculate(List<String> moods) {
    double avgScore = calculateAverageScore(moods);
    String avgMood = scoreToMood(avgScore);
    return {
      "averageScore": avgScore,
      "averageMood": avgMood,
    };
  }
}
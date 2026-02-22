import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String selectedMood = '';
  String selectedEmoji = '';
  final TextEditingController noteController = TextEditingController();

  void selectMood(String mood, String emoji) {
    setState(() {
      selectedMood = mood;
      selectedEmoji = emoji;
    });
  }

  String get formattedDate {
    return "${widget.selectedDate.year}-"
        "${widget.selectedDate.month.toString().padLeft(2, '0')}-"
        "${widget.selectedDate.day.toString().padLeft(2, '0')}";
  }

  Future<void> saveMood() async {
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a mood")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .doc(formattedDate)
        .set({
      'emoji': selectedEmoji,
      'mood': selectedMood,
      'note': noteController.text.trim(),
      'createdAt': Timestamp.fromDate(widget.selectedDate),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayDate =
        "${widget.selectedDate.day} / ${widget.selectedDate.month} / ${widget.selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Mood',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MoodIcon(
                  icon: '😄',
                  label: 'Happy',
                  isSelected: selectedMood == 'Happy',
                  onTap: () => selectMood('Happy', '😄'),
                ),
                MoodIcon(
                  icon: '😐',
                  label: 'Neutral',
                  isSelected: selectedMood == 'Neutral',
                  onTap: () => selectMood('Neutral', '😐'),
                ),
                MoodIcon(
                  icon: '😢',
                  label: 'Sad',
                  isSelected: selectedMood == 'Sad',
                  onTap: () => selectMood('Sad', '😢'),
                ),
                MoodIcon(
                  icon: '😡',
                  label: 'Angry',
                  isSelected: selectedMood == 'Angry',
                  onTap: () => selectMood('Angry', '😡'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Mood Diary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                onPressed: saveMood,
                child: const Text('Save Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodIcon extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
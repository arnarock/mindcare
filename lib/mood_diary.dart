import 'package:flutter/material.dart';

class MoodDiaryPage extends StatefulWidget {
  const MoodDiaryPage({super.key});

  @override
  State<MoodDiaryPage> createState() => _MoodDiaryPageState();
}

class _MoodDiaryPageState extends State<MoodDiaryPage> {
  String selectedMood = '';
  final TextEditingController noteController = TextEditingController();

  void selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  onTap: () => selectMood('Happy'),
                ),
                MoodIcon(
                  icon: '😐',
                  label: 'Neutral',
                  isSelected: selectedMood == 'Neutral',
                  onTap: () => selectMood('Neutral'),
                ),
                MoodIcon(
                  icon: '😢',
                  label: 'Sad',
                  isSelected: selectedMood == 'Sad',
                  onTap: () => selectMood('Sad'),
                ),
                MoodIcon(
                  icon: '😡',
                  label: 'Angry',
                  isSelected: selectedMood == 'Angry',
                  onTap: () => selectMood('Angry'),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved successfully'),
                    ),
                  );
                },
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
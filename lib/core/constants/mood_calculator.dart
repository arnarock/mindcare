/*
* File: mood_calculator.dart
* Description: Provides utility functions to calculate the numerical score and average mood from a list of mood entries, converting between mood labels and corresponding scores for tracking and analysis.
*
* Responsibilities:
* - Convert mood labels into numeric scores.
* - Compute the average score from a list of moods.
* - Map an average score back to a representative mood label.
*
* Authors:
* - Atitaya Khangtan 650510650
* Course: Mobile App Development 
*/
class MoodCalculator {
  /// Mapping of mood labels to their numeric scores
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

  /// Returns the average score from a list of [moods]
  static double calculateAverageScore(List<String> moods) {
    if (moods.isEmpty) return 0;
    int total = 0;
    for (var mood in moods) {
      total += moodScore[mood] ?? 0;
    }
    return total / moods.length;
  }

  /// Returns a mood label based on the average score [avg]
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

  /// Returns both the average score and corresponding mood from [moods]
  static Map<String, dynamic> calculate(List<String> moods) {
    double avgScore = calculateAverageScore(moods);
    String avgMood = scoreToMood(avgScore);
    return {
      "averageScore": avgScore,
      "averageMood": avgMood,
    };
  }
}
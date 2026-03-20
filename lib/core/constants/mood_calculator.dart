/*
* File: mood_calculator.dart
* Description: Provides utility functions to calculate the numerical score and average mood from a list of mood entries, converting between mood labels and corresponding scores for tracking and analysis.
*
* Authors:
* - Atitaya Khangtan 650510650
* Course: Mobile App Development 
*/

/// A utility class for calculating mood scores and converting
/// between mood labels and numerical values.
///
/// Responsibilities:
/// - Convert mood labels into numeric scores
/// - Compute the average score from a list of moods
/// - Map an average score back to a representative mood label
///
/// Notes:
/// - Uses a fixed score mapping for each mood label
/// - Unknown mood labels default to score = 0
class MoodCalculator {

  /// Mapping of mood labels to numerical scores.
  ///
  /// Positive values indicate positive moods,
  /// negative values indicate negative moods.
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

  /// Calculates the average numerical score from a list of mood labels.
  ///
  /// Returns 0 if the list is empty.
  ///
  /// [moods]: A list of mood strings.
  /// Returns the average score as a double.
  static double calculateAverageScore(List<String> moods) {
    if (moods.isEmpty) return 0;
    int total = 0;
    for (var mood in moods) {
      total += moodScore[mood] ?? 0;
    }
    return total / moods.length;
  }

  /// Converts an average score into a corresponding mood label.
  ///
  /// [avg]: The average score as a double.
  /// Returns a string representing the average mood.
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

  /// Calculates both the average score and the corresponding average mood
  /// from a list of mood labels.
  ///
  /// [moods]: A list of mood strings.
  /// Returns a map containing:
  /// - "averageScore": The numerical average score.
  /// - "averageMood": The mood label corresponding to the average score.
  static Map<String, dynamic> calculate(List<String> moods) {
    double avgScore = calculateAverageScore(moods);
    String avgMood = scoreToMood(avgScore);
    return {
      "averageScore": avgScore,
      "averageMood": avgMood,
    };
  }
}
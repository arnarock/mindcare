/*
* File: mood_images.dart
* Description: Defines a mapping between mood states and their corresponding image asset paths for use in the app’s mood tracking and display features.
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/

/// A utility class that defines mappings between mood labels
/// and their corresponding image asset paths.
///
/// This class is used by multiple UI components to retrieve
/// the correct icon representing a user's mood.
///
/// Responsibilities:
/// - Store mapping between mood names and image asset paths
/// - Provide consistent mood icons across the application
/// - Support all main mood states (e.g. Happy, Sad, Stressed)
///
/// Supported moods include:
/// Ecstatic, Excited, Happy, Calm, Bored,
/// Tired, Worried, Sad, Stressed, and None.
///
/// Usage example:
/// ```dart
/// Image.asset(MoodImages.map["Happy"]!)
/// ```
/// 
/// Notes:
/// - The map is static and immutable
/// - Keys must match mood values used throughout the app
/// - Includes a "None" state for unselected mood
class MoodImages {
  
  /// A constant mapping from mood name to image asset path.
  ///
  /// Each key represents a mood state and the value is the
  /// path to the corresponding image stored in the assets folder.
  ///
  /// The "None" mood represents an unselected or neutral state.
  static const Map<String, String> map = {
    "None": "assets/images/moods/mood_none.png",
    "Ecstatic": "assets/images/moods/mood_ecstatic.png",
    "Excited": "assets/images/moods/mood_excited.png",
    "Happy": "assets/images/moods/mood_happy.png",
    "Calm": "assets/images/moods/mood_calm.png",
    "Bored": "assets/images/moods/mood_bored.png",
    "Tired": "assets/images/moods/mood_tired.png",
    "Worried": "assets/images/moods/mood_worried.png",
    "Sad": "assets/images/moods/mood_sad.png",
    "Stressed": "assets/images/moods/mood_stressed.png",
  };
}

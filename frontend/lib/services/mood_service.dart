import 'api_client.dart'; // The foundation of our network layer

class MoodService {
  final ApiClient _apiClient = ApiClient();

  /// Saves or updates the user's mood for the current day.
  /// Takes an emoji string (e.g., "😊") as input.
  /// Returns true on success, false on failure.
  Future<bool> saveMood(String emoji) async {
    final response = await _apiClient.post('/api/moods', {
      'emoji': emoji,
    });
    // A successful save returns a 201 status code, which our controller provides.
    // We check for the presence of the 'mood' object in the response.
    return response['mood'] != null;
  }

  /// Fetches the user's logged mood for today, if one exists.
  /// Returns the emoji string if a mood is found, otherwise returns null.
  Future<String?> getTodaysMood() async {
    final response = await _apiClient.get('/api/moods/today');

    // The backend sends back { "mood": { ... } } or { "mood": null }
    // We safely access the emoji from the nested mood object.
    if (response['mood'] != null && response['mood']['emoji'] != null) {
      return response['mood']['emoji'];
    }
    return null;
  }
}

import 'api_client.dart'; // Import our new, clean client
import '../models/reminder_model.dart'; // Import our new model

/// ReminderService
/// This class handles all reminder-related API calls.
class ReminderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all of the user's reminders
  Future<List<Reminder>> getReminders() async {
    // The 'get' method now returns 'dynamic'
    final response = await _apiClient.get('/reminders');

    // We check if the response is a List, as expected from this endpoint
    if (response is List) {
      // Convert each JSON object in the list into a Reminder model.
      return response.map((json) => Reminder.fromJson(json)).toList();
    }

    // If it's not a list, it's an error. Return an empty list.
    return [];
  }

  /// Creates a new reminder
  Future<Reminder?> createReminder({
    required String title,
    required String time,
    required List<String> days,
  }) async {
    final response = await _apiClient.post('/reminders', {
      'title': title,
      'time': time,
      'days': days,
    });

    // We check if the response is a Map and has no 'error' key
    if (response is Map<String, dynamic> && response['error'] == null) {
      return Reminder.fromJson(response);
    }
    return null;
  }

  /// Updates an existing reminder
  Future<Reminder?> updateReminder(String id, {
    String? title,
    String? time,
    List<String>? days,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (time != null) data['time'] = time;
    if (days != null) data['days'] = days;
    if (isActive != null) data['isActive'] = isActive;

    // This 'put' method now exists
    final response = await _apiClient.put('/reminders/$id', data);

    if (response is Map<String, dynamic> && response['error'] == null) {
      return Reminder.fromJson(response);
    }
    return null;
  }

  /// Deletes a reminder by its ID
  Future<bool> deleteReminder(String id) async {
    // This 'delete' method now exists
    final response = await _apiClient.delete('/reminders/$id');

    // Successful deletion returns a message, not an error
    return (response is Map<String, dynamic> && response['error'] == null);
  }

  /// Marks a reminder as "completed" for the day
  Future<Reminder?> completeReminder(String id) async {
    final response = await _apiClient.post('/reminders/$id/complete', {});

    if (response is Map<String, dynamic> && response['error'] == null) {
      return Reminder.fromJson(response);
    }
    return null;
  }
}


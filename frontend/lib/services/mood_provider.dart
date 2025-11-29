import 'package:flutter/foundation.dart';
//import 'mood_service.dart';
import '../services/api_client.dart';
import '../models/mood_model.dart';

class MoodProvider with ChangeNotifier {
  String? _todaysMoodKeyword;
  String? get todaysMoodKeyword => _todaysMoodKeyword;

  final ApiClient _apiClient = ApiClient();

  // --- NEW: MOOD HISTORY STATE ---
  List<MoodEntry> _moodHistory = [];
  bool _isLoadingHistory = false;

  // We convert the list into a Map for the Calendar to use easily
  // Key: DateTime (normalized to midnight), Value: Mood Keyword
  Map<DateTime, String> _calendarMoods = {};

  Map<DateTime, String> get calendarMoods => _calendarMoods;
  bool get isLoadingHistory => _isLoadingHistory;

  void selectMood(String keyword) {
    _todaysMoodKeyword = keyword;
    notifyListeners();
  }

  // --- NEW: FETCH HISTORY ---
  Future<void> fetchMoodHistory() async {
    _isLoadingHistory = true;
    // Notify listeners immediately so the UI shows a loading spinner
    notifyListeners();

    final response = await _apiClient.get('/moods/history');

    if (response is List) {
      _moodHistory = response.map((json) => MoodEntry.fromJson(json)).toList();
      _generateCalendarMap();
    } else {
      print("Error fetching mood history: $response");
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  // Helper to normalize dates (remove time) so they match the calendar grid
  void _generateCalendarMap() {
    _calendarMoods = {};
    for (var entry in _moodHistory) {
      // Create a date object with just Year, Month, Day
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      _calendarMoods[normalizedDate] = entry.mood;
    }
  }
}
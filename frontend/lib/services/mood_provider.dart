import 'package:flutter/foundation.dart';
import 'mood_service.dart';

class MoodProvider with ChangeNotifier {
  final MoodService _moodService = MoodService();


  String? _todaysMoodKeyword;
  bool _isLoading = false;

  String? get todaysMoodKeyword => _todaysMoodKeyword;
  bool get isLoading => _isLoading;

  Future<void> fetchTodaysMood() async {
    _isLoading = true;
    notifyListeners();
    _todaysMoodKeyword = await _moodService.getTodaysMood();
    _isLoading = false;
    notifyListeners();
  }

  /// Selects a mood, updates the UI, and saves it to the backend.
  Future<void> selectMood(String emoji) async {
    // 1. Optimistic UI Update: Update the local state immediately.
    _todaysMoodKeyword = emoji;
    notifyListeners();

    // --- THIS IS THE FIX ---
    // 2. Save to Backend: Now, we call the MoodService to send the data
    //    to the server in the background.
    await _moodService.saveMood(emoji);
  }
}


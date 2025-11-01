import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'reminder_service.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderService _reminderService = ReminderService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  // --- Main Actions ---

  /// Fetches all reminders from the server and updates the state
  Future<void> fetchReminders() async {
    _setLoading(true);
    _reminders = await _reminderService.getReminders();
    _setLoading(false);
  }

  /// Adds a new reminder and refreshes the list
  Future<bool> addReminder({
    required String title,
    required String time,
    required List<String> days,
  }) async {
    _setLoading(true);
    final newReminder = await _reminderService.createReminder(
      title: title,
      time: time,
      days: days,
    );
    if (newReminder != null) {
      _reminders.add(newReminder);
      _sortAndNotify();
    }
    _setLoading(false);
    return newReminder != null; // Return true on success
  }

  /// Toggles the 'isActive' switch for a reminder
  Future<void> toggleReminderActive(Reminder reminder) async {
    // Optimistic UI: update the state locally first
    reminder.isActive = !reminder.isActive;
    _sortAndNotify();

    // Then, send the update to the server
    final updatedReminder = await _reminderService.updateReminder(
      reminder.id,
      isActive: reminder.isActive,
    );

    if (updatedReminder == null) {
      // If the server update failed, revert the change
      reminder.isActive = !reminder.isActive;
      _sortAndNotify();
    }
  }

  /// DeMarks a reminder as completed for the day
  Future<void> markAsCompleted(Reminder reminder) async {
    final updatedReminder = await _reminderService.completeReminder(reminder.id);

    if (updatedReminder != null) {
      // Find the reminder in the list and replace it with the updated one
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        _sortAndNotify();
      }
    }
  }

  /// Deletes a reminder
  Future<void> deleteReminder(String id) async {
    // Optimistic UI: remove from list first
    _reminders.removeWhere((r) => r.id == id);
    _sortAndNotify();

    // Then, send the update to the server
    final success = await _reminderService.deleteReminder(id);

    if (!success) {
      // If it failed, put it back (or just refetch all)
      fetchReminders();
    }
  }

  // --- Helper Methods ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _sortAndNotify() {
    // Sorts reminders by time
    _reminders.sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
  }
}

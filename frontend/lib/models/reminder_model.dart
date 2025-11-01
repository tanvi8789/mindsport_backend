import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String time; // Stored as "HH:mm"
  final List<String> days; // e.g., ['mon', 'tue']
  bool isActive;
  final DateTime? lastCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.days,
    required this.isActive,
    this.lastCompleted,
  });

  // Factory constructor to create a Reminder from JSON (data from API)
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['_id'],
      title: json['title'],
      time: json['time'],
      // Safely parse the 'days' array
      days: List<String>.from(json['days'] ?? []),
      isActive: json['isActive'] ?? true,
      // Safely parse the date, which might be null
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'])
          : null,
    );
  }

  // Method to convert a Reminder object to JSON (to send to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'days': days,
      'isActive': isActive,
    };
  }

  // --- Helper Logic for the "Check-off" Feature ---

  // Helper to check if the reminder has been completed today.
  bool get isCompletedToday {
    if (lastCompleted == null) {
      return false; // Never completed
    }

    final now = DateTime.now();
    final last = lastCompleted!;

    // Check if the last completion was on the same day, month, and year as today
    return now.day == last.day &&
        now.month == last.month &&
        now.year == last.year;
  }
}

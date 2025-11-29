class MoodEntry {
  final String id;
  final String mood; // 'happy', 'sad', etc.
  final String? reason;
  final DateTime date;

  MoodEntry({
    required this.id,
    required this.mood,
    this.reason,
    required this.date,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['_id'],
      mood: json['mood'],
      reason: json['reason'],
      // Parse the ISO date string from MongoDB
      date: DateTime.parse(json['createdAt']),
    );
  }
}
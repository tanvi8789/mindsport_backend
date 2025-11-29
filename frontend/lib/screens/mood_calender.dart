import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/services/mood_provider.dart';
import 'package:mindsport/main.dart'; // For theme colors

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoodProvider>(context, listen: false).fetchMoodHistory();
    });
  }

  // Define colors for each mood
  Color _getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return MindSportTheme.primaryGreen; // Green
      case 'excited':
        return Colors.orangeAccent;
      case 'neutral':
        return Colors.grey;
      case 'sad':
        return Colors.blueGrey;
      case 'angry':
        return Colors.redAccent;
      default:
        return MindSportTheme.softLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          if (moodProvider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),

                    // --- THE MAGIC HAPPENS HERE ---
                    calendarBuilders: CalendarBuilders(
                      // Custom builder for default days
                        defaultBuilder: (context, day, focusedDay) {
                          // Check if we have a mood for this day
                          // Normalize the day to remove time parts for comparison
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          final mood = moodProvider.calendarMoods[normalizedDay];

                          if (mood != null) {
                            // If there IS a mood, return a colored circle
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: _getColorForMood(mood).withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          // Otherwise return null (default view)
                          return null;
                        },

                        // Also apply this to 'today' so it doesn't get overridden by default styling
                        todayBuilder: (context, day, focusedDay) {
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          final mood = moodProvider.calendarMoods[normalizedDay];

                          if (mood != null) {
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: _getColorForMood(mood), // Solid color for today
                                  shape: BoxShape.circle,
                                  border: Border.all(color: MindSportTheme.darkText, width: 2)
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return null;
                        }
                    ),

                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              ),

              // Simple Legend
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LegendItem(color: Color(0xFF6B8E23), label: 'Happy'),
                    _LegendItem(color: Colors.orangeAccent, label: 'Excited'),
                    _LegendItem(color: Colors.blueGrey, label: 'Sad'),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
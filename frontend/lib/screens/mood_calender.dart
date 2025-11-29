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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoodProvider>(context, listen: false).fetchMoodHistory();
    });
  }

  // --- 1. DEFINING COLORS FOR ALL 5 MOODS ---
  Color _getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
        return Colors.orangeAccent; // Energetic Orange
      case 'happy':
        return MindSportTheme.primaryGreen; // Earthy Green
      case 'neutral':
        return Colors.grey; // Calm Grey
      case 'sad':
        return const Color(0xFF7986CB); // Muted Indigo/Blue
      case 'angry':
        return const Color(0xFFE57373); // Soft Red
      default:
        return MindSportTheme.softGreen;
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

          return SingleChildScrollView( // Added scroll for smaller screens
            child: Column(
              children: [
                // --- CALENDAR CARD ---
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
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final normalizedDay = DateTime(day.year, day.month, day.day);
                            final mood = moodProvider.calendarMoods[normalizedDay];

                            if (mood != null) {
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: _getColorForMood(mood).withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              );
                            }
                            return null;
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final normalizedDay = DateTime(day.year, day.month, day.day);
                            final mood = moodProvider.calendarMoods[normalizedDay];

                            if (mood != null) {
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                    color: _getColorForMood(mood),
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
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: MindSportTheme.softLavender.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: MindSportTheme.darkText, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                      ),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    ),
                  ),
                ),

                // --- 2. UPDATED LEGEND (ALL 5 MOODS) ---
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Wrap( // Using Wrap instead of Row to handle small screens better
                    alignment: WrapAlignment.center,
                    spacing: 16.0,
                    runSpacing: 10.0,
                    children: [
                      _LegendItem(color: Colors.orangeAccent, label: 'Excited'),
                      _LegendItem(color: Color(0xFF6B8E23), label: 'Happy'), // Theme Green
                      _LegendItem(color: Colors.grey, label: 'Neutral'),
                      _LegendItem(color: Color(0xFF7986CB), label: 'Sad'),
                      _LegendItem(color: Color(0xFFE57373), label: 'Angry'),
                    ],
                  ),
                )
              ],
            ),
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
      mainAxisSize: MainAxisSize.min, // Keep items compact
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
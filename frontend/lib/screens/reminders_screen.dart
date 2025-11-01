import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_provider.dart';
import 'add_reminder_screen.dart';
import 'package:provider/provider.dart';

// Note: I removed the UserProvider import, as we don't need it here anymore

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reminders when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // --- THIS IS THE FIX ---
      // We just call fetchReminders(). The provider and service
      // already know how to get the user from the auth token.
      Provider.of<ReminderProvider>(context, listen: false).fetchReminders();
      // --- END OF FIX ---
    });
  }

  // Helper to get an icon based on the title
  IconData _getIconForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('mindfulness')) {
      return Icons.self_improvement;
    }
    if (title.contains('visualization')) {
      return Icons.visibility;
    }
    if (title.contains('journal')) {
      return Icons.book_outlined;
    }
    return Icons.alarm;
  }

  // Helper to format "HH:mm" time
  String _formatTime(String time) {
    try {
      final a = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      return a.format(context);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders scheduled.\nTap the + button to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Scheduled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              ...provider.reminders.map((reminder) {
                return _buildReminderCard(context, provider, reminder);
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
          );
        },
        backgroundColor: const Color(0xFFC8E6C9),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildReminderCard(
      BuildContext context,
      ReminderProvider provider,
      Reminder reminder,
      ) {
    final bool isActive = reminder.isActive;
    final bool isCompleted = reminder.isCompletedToday;

    return Card(
      color: isActive ? const Color(0xFFF3E5F5) : Colors.grey.shade200,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(reminder.title),
              color: isActive ? Colors.black87 : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Text(
                    'Scheduled for ${_formatTime(reminder.time)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.black54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isCompleted,
              onChanged: (isActive && !isCompleted)
                  ? (bool? value) {
                if (value == true) {
                  provider.markAsCompleted(reminder);
                }
              }
                  : null,
              activeColor: Colors.deepPurple,
            ),
            Switch(
              value: isActive,
              onChanged: (bool value) {
                provider.toggleReminderActive(reminder);
              },
              activeColor: Colors.deepPurple.shade300,
            ),
          ],
        ),
      ),
    );
  }
}


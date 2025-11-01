import 'package:flutter/material.dart';
import '../services/reminder_provider.dart';
import 'package:provider/provider.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  TimeOfDay? _selectedTime;

  // Map to hold the state of our day selection chips
  final Map<String, String> _days = {
    'Mon': 'mon',
    'Tue': 'tue',
    'Wed': 'wed',
    'Thu': 'thu',
    'Fri': 'fri',
    'Sat': 'sat',
    'Sun': 'sun',
  };
  final Set<String> _selectedDays = {}; // e.g., {'mon', 'fri'}
  bool _isLoading = false;

  // Function to show the time picker
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  // Function to save the reminder
  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // Convert TimeOfDay to "HH:mm" string
    final timeString = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    final success = await Provider.of<ReminderProvider>(context, listen: false)
        .addReminder(
      title: _titleController.text,
      time: timeString,
      days: _selectedDays.toList(),
    );

    setState(() { _isLoading = false; });

    if (success && mounted) {
      Navigator.of(context).pop(); // Go back to the reminders list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save reminder. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color is set in main.dart
      appBar: AppBar(
        title: const Text('Add Reminder', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title Field ---
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Time Picker ---
            ListTile(
              onTap: _pickTime,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              trailing: Text(
                _selectedTime?.format(context) ?? 'Select Time',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTime != null ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Day Selector ---
            const Text(
              'Repeat on',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _days.entries.map((day) {
                final isSelected = _selectedDays.contains(day.value);
                return FilterChip(
                  label: Text(day.key),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day.value);
                      } else {
                        _selectedDays.remove(day.value);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.deepPurple.shade100,
                  checkmarkColor: Colors.deepPurple,
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Reminder',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


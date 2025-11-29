import 'package:flutter/material.dart';
import '../services/reminder_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import theme

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
      // Optional: Add a builder to theme the time picker
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: MindSportTheme.primaryGreen, // Header background
              onPrimary: Colors.white, // Header text
              onSurface: MindSportTheme.darkText, // Body text
            ),
            dialogBackgroundColor: MindSportTheme.primaryBackground,
          ),
          child: child!,
        );
      },
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
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day to repeat')),
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
        title: const Text('Add Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // --- 1. THE ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(), // Use the same painter
            size: Size.infinite,
          ),

          // --- 2. THE SCROLLING FORM ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Title Field ---
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    // --- THIS IS THE FIX ---
                    // This overrides the theme's default (0.8) to match the time picker
                    fillColor: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Time Picker ---
                ListTile(
                  onTap: _pickTime,
                  tileColor: Colors.white.withOpacity(0.85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.access_time, color: MindSportTheme.darkText),
                  title: const Text('Time'),
                  trailing: Text(
                    _selectedTime?.format(context) ?? 'Select Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedTime != null ? MindSportTheme.darkText : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Day Selector ---
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Repeat on',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: MindSportTheme.darkText),
                  ),
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
                      backgroundColor: Colors.white.withOpacity(0.8),
                      selectedColor: MindSportTheme.softLavender.withOpacity(0.9),
                      checkmarkColor: Colors.deepPurple,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // --- Save Button ---
                SizedBox(
                  width: double.infinity,
                  // The ElevatedButtonTheme in main.dart will style this
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Reminder'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- We copy the background painter ---
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;

    final paint1 = Paint()
      ..color = MindSportTheme.softPeach.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint2 = Paint()
      ..color = MindSportTheme.softLavender.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint3 = Paint()
      ..color = MindSportTheme.softGreen.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


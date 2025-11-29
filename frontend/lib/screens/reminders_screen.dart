import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_provider.dart';
import 'add_reminder_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import theme

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

// --- ANIMATION ---
// Add the SingleTickerProviderStateMixin
class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // --- ANIMATION ---
    // Setup the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch reminders when the screen loads
      Provider.of<ReminderProvider>(context, listen: false).fetchReminders();
      // --- ANIMATION ---
      // Start the animation
      _animationController.forward();
    });
  }

  // --- ANIMATION ---
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to get an icon based on the title, like in your design
  IconData _getIconForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('mindfulness')) {
      return Icons.self_improvement; // Matches your "meditation" icon
    }
    if (title.contains('visualization')) {
      return Icons.visibility; // Matches your "eye" icon
    }
    if (title.contains('journal')) {
      return Icons.book_outlined; // Matches your "journal" icon
    }
    return Icons.alarm; // Default
  }

  // Helper to format "HH:mm" time to "h:mm AM/PM"
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
      // The background color is set in main.dart
      appBar: AppBar(
        title: const Text(
          'Reminders',
          // The theme in main.dart will style this
        ),
        // The theme in main.dart makes this transparent
      ),
      body: Stack(
        children: [
          // --- 1. THE ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. THE SCROLLING CONTENT ---
          Consumer<ReminderProvider>(
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

              // --- ANIMATION ---
              // Wrap the ListView in the FadeTransition
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.reminders.length + 1, // +1 for the header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // --- Header ---
                      return const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 10.0),
                        child: Text(
                          'Scheduled',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    final reminder = provider.reminders[index - 1];
                    // --- ANIMATION ---
                    // Wrap each card in the slide animation
                    return _FadeInSlide(
                      animation: _fadeAnimation,
                      delay: (index * 0.1).clamp(0.0, 1.0), // Stagger the cards
                      child: _buildReminderCard(context, provider, reminder),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the new "Add Reminder" screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
          );
        },
        backgroundColor: MindSportTheme.primaryGreen, // Use theme color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds the interactive card for a single reminder
  Widget _buildReminderCard(
      BuildContext context,
      ReminderProvider provider,
      Reminder reminder,
      ) {
    final bool isActive = reminder.isActive;
    final bool isCompleted = reminder.isCompletedToday;

    return Card(
      // --- THEME FIX ---
      // Use the theme color with opacity
      color: isActive ? MindSportTheme.softLavender.withOpacity(0.85) : Colors.grey.shade200.withOpacity(0.85),
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
            // This is the "Check-off" box
            Checkbox(
              value: isCompleted,
              onChanged: (isActive && !isCompleted)
                  ? (bool? value) {
                if (value == true) {
                  provider.markAsCompleted(reminder);
                }
              }
                  : null, // Disabled if not active or already completed
              activeColor: Colors.deepPurple,
            ),
            // This is the "On/Off" toggle from your design
            Switch(
              value: isActive,
              onChanged: (bool value) {
                provider.toggleReminderActive(reminder);
              },
              activeColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// --- We copy the helper classes from home_screen.dart ---

// --- WIDGET FOR THE BACKGROUND ---
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

// --- WIDGET FOR ANIMATION ---
class _FadeInSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;

  const _FadeInSlide({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - curvedAnimation.value) * 30),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// --- PLACEHOLDER CLASS REMOVED ---
// The old placeholder 'AddReminderScreen' class is now gone.


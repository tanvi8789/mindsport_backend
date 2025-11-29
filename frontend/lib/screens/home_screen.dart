import 'package:flutter/material.dart';
import '../services/mood_provider.dart';
import '../services/user_provider.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart'; // Import theme

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // Fetch user data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.fetchUserData();
      }
      // Start the animation
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ... (Your _submitMood function remains the same) ...
  Future<void> _submitMood(BuildContext context) async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final moodKeyword = moodProvider.todaysMoodKeyword;
    final userId = userProvider.user?.id; // Get the real user ID

    if (moodKeyword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first!')),
      );
      return;
    }
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please restart.')),
      );
      return;
    }

    const String apiUrl = 'https://mindsport-backend.onrender.com/api/moods';
    final Map<String, dynamic> body = {
      'mood': moodKeyword,
      'reason': '', // You can add a text field for this later
      'userId': userId,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saving mood...'),
        backgroundColor: MindSportTheme.softLavender,
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // We need to send the auth token to the 'protect' middleware
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mood saved successfully!'),
            backgroundColor: MindSportTheme.primaryGreen, // Use theme color
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error from server: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection Error: ${e.runtimeType}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Athlete';

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(),
      body: Stack(
        children: [
          // --- 1. THE ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. THE SCROLLING CONTENT ---
          FadeTransition(
            opacity: _fadeAnimation, // Apply the fade animation here
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '🌱 Hello, $userName!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: MindSportTheme.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Mood Card ---
                  // We wrap each card in our new animation widget
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.1, // Start after a small delay
                    child: _buildMoodCard(context, moodProvider),
                  ),
                  const SizedBox(height: 16),

                  // --- Save Mood Button ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitMood(context),
                        style: ElevatedButton.styleFrom(
                          // --- COLOR FIX ---
                          // This now uses the primary green for a clear call to action
                          backgroundColor: MindSportTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 2, // A very subtle shadow
                        ),
                        child: const Text('Save Today\'s Mood'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Quote Card ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: _buildQuoteCard(),
                  ),
                  const SizedBox(height: 24),

                  // --- Reminders Card ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.4,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'Check your reminders',
                      color: MindSportTheme.softLavender,
                      icon: Icons.alarm,
                      routeName: '/reminders',
                    ),
                  ),
                  const SizedBox(height: 100), // Extra space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: MindSportTheme.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // ... (_buildMoodCard, _buildQuoteCard, _buildNavigationCard methods are unchanged) ...
  // ... They will be picked up by the animation wrappers automatically ...

  /// Builds the top card for mood selection
  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited',
      '😊': 'happy',
      '😐': 'neutral',
      '😢': 'sad',
      '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    // The CardTheme from main.dart handles the shape
    return Card(
      // --- OPACITY CHANGE ---
      color: MindSportTheme.softGreen.withOpacity(0.85), // Use theme color with opacity
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: MindSportTheme.darkText // Use theme color
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: emojiOptions.map((emoji) {
                final isSelected =
                    moodProvider.todaysMoodKeyword == moodMap[emoji];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final keyword = moodMap[emoji];
                      if (keyword != null) {
                        moodProvider.selectMood(keyword);
                      }
                    },
                    child: Container(
                      color: Colors.transparent, // Makes the whole area tappable
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.5)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the middle card for the motivational quote
  Widget _buildQuoteCard() {
    return Card(
      // --- OPACITY CHANGE ---
      color: MindSportTheme.softPeach.withOpacity(0.85), // Use theme color with opacity
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Text(
          ' 💫 "The sky has no limits, neither should you" 💫',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: MindSportTheme.darkText, // Use theme color
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Builds a generic card to navigate to another page
  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      // --- OPACITY CHANGE ---
      color: color.withOpacity(0.85), // Use theme color with opacity
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(20), // Matches card shape
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: MindSportTheme.darkText, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: MindSportTheme.darkText,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: MindSportTheme.darkText),
            ],
          ),
        ),
      ),
    );
  }
}
// --- NEW WIDGET FOR THE BACKGROUND ---
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --- INTENSITY CHANGE ---
    // We decrease the blur to make the colors more present
    const double blurSigma = 45.0;

    // Soft Peach color
    final paint1 = Paint()
    // --- INTENSITY CHANGE ---
      ..color = MindSportTheme.softPeach.withOpacity(0.5) // Was 0.3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Soft Lavender color
    final paint2 = Paint()
    // --- INTENSITY CHANGE ---
      ..color = MindSportTheme.softLavender.withOpacity(0.6) // Was 0.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Soft Green color
    final paint3 = Paint()
    // --- INTENSITY CHANGE ---
      ..color = MindSportTheme.softGreen.withOpacity(0.5) // Was 0.3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Draw three large, overlapping circles to create a soft gradient
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // This background never needs to change
  }
}

// --- NEW WIDGET FOR ANIMATION ---
// This simple widget will fade in and slide up its child
class _FadeInSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay; // A value between 0.0 and 1.0
  final Widget child;

  const _FadeInSlide({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // We create a new "curved" animation that only runs
    // for a part of the main animation's duration
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      // This curve makes it start after the delay, and finish quickly
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Transform.translate(
          // Slide up from 30 pixels below
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


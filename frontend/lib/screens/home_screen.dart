import 'package:flutter/material.dart';
import 'package:mindsport/services/mood_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/screens/sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import the theme colors we defined in main.dart
import 'package:mindsport/main.dart';

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
    // Animation setup: Runs for 800ms
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // A nice fluid curve
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Fetch user data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.fetchUserData();
      }
      // Start the animation immediately
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Logic to save the mood to the backend
  Future<void> _submitMood(BuildContext context) async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final moodKeyword = moodProvider.todaysMoodKeyword;
    final userId = userProvider.user?.id;

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
      'reason': '',
      'userId': userId,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saving mood...'),
        backgroundColor: MindSportTheme.softLavender,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mood saved successfully!'),
              backgroundColor: MindSportTheme.primaryGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from server: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection Error: ${e.runtimeType}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Athlete';

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        // Transparent AppBar to show the background
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      // Use a Stack to layer the background painter behind the content
      body: Stack(
        children: [
          // --- 1. ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. SCROLLABLE CONTENT ---
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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

                  // Mood Card (Staggered Animation 1)
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.0,
                    child: _buildMoodCard(context, moodProvider),
                  ),
                  const SizedBox(height: 16),

                  // Save Mood Button (Staggered Animation 2)
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitMood(context),
                        style: ElevatedButton.styleFrom(
                          // Strong CTA color
                          backgroundColor: MindSportTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Save Today\'s Mood',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mood Calendar Button (Staggered Animation 3)
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'View Mood Calendar',
                      color: MindSportTheme.softGreen,
                      icon: Icons.calendar_month,
                      routeName: '/history',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quote Card (Staggered Animation 4)
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: _buildQuoteCard(),
                  ),
                  const SizedBox(height: 24),

                  // Reminders Card (Staggered Animation 5)
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

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Chat Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: MindSportTheme.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited',
      '😊': 'happy',
      '😐': 'neutral',
      '😢': 'sad',
      '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    return Card(
      // Semi-transparent background
      color: MindSportTheme.softGreen.withOpacity(0.85),
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
                  color: MindSportTheme.darkText),
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
                      color: Colors.transparent,
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

  Widget _buildQuoteCard() {
    return Card(
      color: MindSportTheme.softPeach.withOpacity(0.85),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Text(
          ' 💫 "The sky has no limits, neither should you" 💫',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: MindSportTheme.darkText,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      color: color.withOpacity(0.85),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(20),
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

// --- ANIMATION & BACKGROUND CLASSES ---

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Increased intensity by lowering blur slightly and increasing opacity
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
    // Calculates the specific interval for this widget's animation
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
          delay,
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic
      ),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Transform.translate(
          // Slide up from 30px down
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
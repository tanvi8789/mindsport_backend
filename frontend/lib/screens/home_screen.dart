import 'package:flutter/material.dart';
import 'package:mindsport/services/mood_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/screens/sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mindsport/main.dart'; // Import theme

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
    // Setup smooth entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    // Fetch user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.fetchUserData();
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // UPDATED: Now accepts the mood directly to save immediately
  Future<void> _submitMood(BuildContext context, String moodKeyword) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

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

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Mood saved successfully!'), backgroundColor: MindSportTheme.primaryGreen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection Error'), backgroundColor: Colors.red),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      body: Stack(
        children: [
          // --- 1. ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. CONTENT ---
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

                  // Mood Card
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.0,
                    child: _buildMoodCard(context, moodProvider),
                  ),
                  const SizedBox(height: 24), // Increased spacing slightly since button is gone

                  // Quote Card
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: _buildQuoteCard(),
                  ),
                  const SizedBox(height: 24),

                  // Reminders Card
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'Check your reminders',
                      color: MindSportTheme.softLavender,
                      icon: Icons.alarm,
                      routeName: '/reminders',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mood Calendar Button (Moved here)
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.4,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'View Mood Calendar',
                      color: MindSportTheme.softGreen,
                      icon: Icons.calendar_month,
                      routeName: '/history',
                    ),
                  ),

                  const SizedBox(height: 100),
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

  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited', '😊': 'happy', '😐': 'neutral', '😢': 'sad', '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    return Card(
      color: MindSportTheme.softGreen.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: MindSportTheme.darkText),
            ),
            const SizedBox(height: 20),
            Row(
              children: emojiOptions.map((emoji) {
                final isSelected = moodProvider.todaysMoodKeyword == moodMap[emoji];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final keyword = moodMap[emoji];
                      if (keyword != null) {
                        // 1. Visually select it
                        moodProvider.selectMood(keyword);
                        // 2. Automatically save it
                        _submitMood(context, keyword);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36)),
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
          style: TextStyle(fontSize: 18, color: MindSportTheme.darkText, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({required BuildContext context, required String title, required Color color, required IconData icon, required String routeName}) {
    return Card(
      color: color.withOpacity(0.85),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
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
                  Text(title, style: const TextStyle(fontSize: 18, color: MindSportTheme.darkText, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
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

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;
    final paint1 = Paint()..color = MindSportTheme.softPeach.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint2 = Paint()..color = MindSportTheme.softLavender.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint3 = Paint()..color = MindSportTheme.softGreen.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FadeInSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;
  const _FadeInSlide({required this.animation, required this.delay, required this.child});
  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic));
    return AnimatedBuilder(animation: curvedAnimation, builder: (context, child) {
      return Transform.translate(offset: Offset(0, (1.0 - curvedAnimation.value) * 30), child: Opacity(opacity: curvedAnimation.value, child: child));
    }, child: child);
  }
}
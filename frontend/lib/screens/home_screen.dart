import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_provider.dart';
import '../services/mood_provider.dart';
import 'sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
      Provider.of<MoodProvider>(context, listen: false).fetchTodaysMood();
    });
  }

  // --- THIS IS THE NEW FUNCTION, NOW INSIDE YOUR _HomeScreenState ---
  Future<void> _submitMood(BuildContext context) async {
    // --- DEBUG STEP 1: Check if the button is even firing ---
    print("--- Submit Mood Function Started ---");

    // We can access both providers here
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final moodKeyword = moodProvider.todaysMoodKeyword;
    final userId = userProvider.user?.id; // Get the REAL user ID

    if (moodKeyword == null) {
      // --- DEBUG STEP 2: Check if a mood was selected ---
      print("Execution STOPPED: No mood keyword was selected in the provider.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first!')),
      );
      return;
    }

    if (userId == null) {
      // --- (NEW) DEBUG STEP 2.5: Check that we have a user ID ---
      print("Execution STOPPED: User ID is null. User might not be logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not found. Please restart.')),
      );
      return;
    }

    // --- DEBUG STEP 3: Verify the data and URL before sending ---
    // IMPORTANT: Double-check that this IP address is correct!
    const String apiUrl = 'https://mindsport-backend.onrender.com/api/moods'; // <-- CHECK YOUR IP
    final Map<String, dynamic> body = {
      'mood': moodKeyword,
      'reason': '', // You can add a text field for this later
      'userId': userId // We are now using the REAL user ID
    };

    print("Attempting to send POST request to: $apiUrl");
    print("Request body: ${jsonEncode(body)}");

    try {
      // --- DEBUG STEP 4: The actual network request ---
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      print("--- Response Received ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error from server: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // --- DEBUG STEP 5: Catching any and all errors ---
      print("---!! ERROR CAUGHT !! ---");
      print("An error occurred while sending the request: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: ${e.runtimeType}'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF2F0EC),
      body: Stack(
        children: [
          Consumer2<UserProvider, MoodProvider>(
            builder: (context, userProvider, moodProvider, child) {
              if (userProvider.isLoading || moodProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final userName = userProvider.user?.name ?? 'there';
              // Removed a syntax error that was here (textAlign: TextAlign.center;)

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.black87),
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🌱 Hello, $userName!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 30),
                              _buildMoodCard(context, moodProvider),
                              const SizedBox(height: 20),

                              // --- THIS IS THE NEW "SAVE" BUTTON ---
                              Center(
                                child: ElevatedButton(
                                  onPressed: () => _submitMood(context), // Calls the new function
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF333333),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Save Mood'),
                                ),
                              ),
                              // ------------------------------------

                              const SizedBox(height: 20),
                              _buildQuoteCard(),
                              const SizedBox(height: 20),
                              _buildCalendarCard(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 40,
            right: 25,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/chat'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black54, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.black87, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  // (Your existing widgets are below)

  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited',
      '😊': 'happy',
      '😐': 'neutral',
      '😢': 'sad',
      '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD5DABA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
                color: Color(0xFF333333)
            ),
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
                      // This just updates the provider, which is correct.
                      moodProvider.selectMood(keyword);
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
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFFF3CEB3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        ' 💫 The sky has no limits, neither should you 💫',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Color(0xFF333333), fontFamily: 'Nunito'),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        color: const Color(0xFFBAC0DA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          'Calendar of mood emojis',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Color(0xFF333333), fontFamily: 'Nunito'),
        ),
      ),
    );
  }
}


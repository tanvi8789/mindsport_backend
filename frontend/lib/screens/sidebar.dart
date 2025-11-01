import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the UserProvider for the logout action
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Drawer(
          child: Container(
            color: const Color(0xFF2D2D2D), // Matching the dark background
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 24.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'mindsport.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(), // Closes the drawer
                      )
                    ],
                  ),
                ),
                // --- Navigation Items ---
                _buildListTile(icon: Icons.home_outlined, title: 'Home', onTap: () => Navigator.pushNamed(context, '/home')),
                _buildListTile(icon: Icons.chat_bubble_outline, title: 'ChatBot', onTap: () => Navigator.pushNamed(context, '/chat')),
                _buildListTile(icon: Icons.forum_outlined, title: 'Community Forum', onTap: () => Navigator.pushNamed(context, '/forum')),
                //_buildListTile(icon: Icons.favorite_border, title: 'Mood Check-ins', onTap: () => Navigator.pushNamed(context, '/mood-checkin')),
                _buildListTile(icon: Icons.notifications_none, title: 'Reminders', onTap: () => Navigator.pushNamed(context, '/reminders')),

                const Spacer(), // Pushes the bottom items down

                // --- Bottom Profile & Logout ---
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.white, radius: 16),
                  title: const Text('User Profile', style: TextStyle(color: Colors.white70)),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    label: const Text('Logout', style: TextStyle(color: Colors.white70)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Call the provider's logout method
                      userProvider.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.9)),
      title: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9))),
      onTap: onTap,
    );
  }
}

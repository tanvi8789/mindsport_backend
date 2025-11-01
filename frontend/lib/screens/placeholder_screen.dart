import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF2F0EC),
      ),
      body: Center(
        child: Text(
          'This is the $title screen.',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

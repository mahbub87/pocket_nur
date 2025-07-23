import 'package:flutter/material.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: const Center(
        child: Text(
          'Prayer Times Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: const Center(
        child: Text(
          'Quran Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith')),
      body: const Center(
        child: Text(
          'Hadith Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

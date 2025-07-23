import 'package:flutter/material.dart';

class PillarsScreen extends StatelessWidget {
  const PillarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pillars of Islam')),
      body: const Center(
        child: Text(
          'Pillars Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
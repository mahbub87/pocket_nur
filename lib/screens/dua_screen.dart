import 'package:flutter/material.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dua')),
      body: const Center(
        child: Text(
          'Dua Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

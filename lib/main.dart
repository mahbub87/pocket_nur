import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PocketNurApp());
}

class PocketNurApp extends StatelessWidget {
  const PocketNurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pocket Nur',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomeScreen(),
    );
  }
}

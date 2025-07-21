import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/home_controller.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const PocketNurApp());
}

class PocketNurApp extends StatelessWidget {
  const PocketNurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pocket Nur',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

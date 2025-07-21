import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.mood),
        title: const Text('Mood Selector'),
        onTap: () {},
      ),
    );
  }
}

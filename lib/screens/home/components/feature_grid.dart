import 'package:flutter/material.dart';
import '../../quran_screen.dart';
import '../../hadith_screen.dart';
import '../../pillars_screen.dart';
import '../../dua_screen.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      ('Quran', Icons.menu_book, const QuranScreen()),
      ('Hadith', Icons.book, const HadithScreen()),
      ('5 Pillars', Icons.view_in_ar, const PillarsScreen()),
      ('Dua', Icons.pan_tool_alt, const DuaScreen()),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3, // Make boxes less tall (increase for smaller boxes)
      children: features
          .map((f) => _buildFeatureButton(context, f.$1, f.$2, f.$3))
          .toList(),
    );
  }

  Widget _buildFeatureButton(
      BuildContext context, String label, IconData icon, Widget screen) {
    return SizedBox(
      height: 80, // Reduce height
      width: 80,  // Reduce width
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32), // Slightly smaller icon
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
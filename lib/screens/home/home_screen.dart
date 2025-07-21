import 'package:flutter/material.dart';
import 'components/top_row.dart';
import 'components/prayer_card.dart';
import 'components/feature_grid.dart';
import 'components/mood_selector.dart';
import 'components/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TopRow(),
              SizedBox(height: 16),
              PrayerCard(),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              FeatureGrid(),
              SizedBox(height: 16),
              MoodSelector(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

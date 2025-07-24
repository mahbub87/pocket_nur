import 'package:flutter/material.dart';
import 'package:pocket_nur/services/quran_service.dart';
import 'package:pocket_nur/screens/surah_screen.dart'; 
import 'package:pocket_nur/screens/quran_search_screen.dart'; 

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();
  // In a real app, you'd likely fetch a list of surahs here
  final List<String> _surahNames = List.generate(114, (index) => 'Surah ${index + 1}'); // Placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranSearchScreen()));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _surahNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_surahNames[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahScreen(surahNumber: index + 1), // Pass surah number
                ),
              );
            },
          );
        },
      ),
    );
  }
}
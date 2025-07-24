import 'package:flutter/material.dart';
import 'package:pocket_nur/services/quran_service.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;

  const SurahScreen({super.key, required this.surahNumber});

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final QuranService _quranService = QuranService();
  Map<String, dynamic>? _surahData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  void _fetchSurah() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic>? data = await _quranService.getSurah(widget.surahNumber);
    setState(() {
      _surahData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Surah ${widget.surahNumber}')), // Display surah number in AppBar
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahData == null
              ? const Center(child: Text('Could not load surah.'))
              : ListView.builder(
                  itemCount: (_surahData!['ayahs'] as List).length,
                  itemBuilder: (context, index) {
                    final ayat = _surahData!['ayahs'][index];
                    return ListTile(
                      title: Text('Ayat ${index + 1}'), // Display ayat number (assuming they are in order)
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ayat['text'] ?? ''),
                          Text(ayat['translation'] ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
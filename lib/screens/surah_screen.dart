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
  List<Map<String, dynamic>> _ayahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurahAndAyahs();
  }

  Future<void> _fetchSurahAndAyahs() async {
    setState(() {
      _isLoading = true;
    });

    final surah = await _quranService.getSurah(widget.surahNumber);
    final ayahs = await _quranService.getAyahsForSurah(widget.surahNumber);

    setState(() {
      _surahData = surah;
      _ayahs = ayahs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_surahData != null
            ? _surahData!['name'] ?? 'Surah ${widget.surahNumber}'
            : 'Surah ${widget.surahNumber}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surahData == null
              ? const Center(child: Text('Could not load surah.'))
              : ListView.builder(
                  itemCount: _ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = _ayahs[index];
                    return ListTile(
                      title: Text('Ayah ${ayah['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ayah['text'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            ayah['translation'] ?? '',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

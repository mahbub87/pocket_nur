import 'package:flutter/material.dart';
import 'package:pocket_nur/services/quran_service.dart';

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  _QuranSearchScreenState createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final QuranService _quranService = QuranService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> results = await _quranService.searchAyahs(_searchController.text);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Quran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter keywords',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final ayat = _searchResults[index];
                        return ListTile(
                          title: Text('Surah ${ayat['surah']} Ayat ${ayat['ayat_number'] ?? 'N/A'}'), // Assuming ayahs have an ayat_number field
                          subtitle: Text(ayat['translation'] ?? 'No translation available'),
                          // You might want to add more details or navigate to the Surah screen on tap
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
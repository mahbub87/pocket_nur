import 'package:flutter/material.dart';
import 'package:pocket_nur/services/quran_service.dart';
import 'package:pocket_nur/screens/surah_screen.dart'; // Assuming you have a SurahScreen
import 'package:pocket_nur/screens/quran_search_screen.dart'; // Assuming you have a QuranSearchScreen

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();
  List<dynamic> _surahs = [];
  String _searchText = '';
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadQuranData();
  }

  Future<void> _loadQuranData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final data = await _quranService.getAllSurahs();
      setState(() {
        _surahs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load Quran data: ${e.toString()}';
        print('Error loading Quran data: $e'); // Print the error to the console as well
      });
    }
  }

  List<dynamic> get _filteredSurahs {
    if (_searchText.isEmpty) {
      return _surahs;
    }
    return _surahs.where((surah) {
      // Check for null or unexpected types before calling toLowerCase() and contains() 
      final name = surah['name'];
      final arabicName = surah['nameAr'];

      bool nameMatches = false;
      if (name is String) {
        nameMatches = name.toLowerCase().contains(_searchText.toLowerCase());
      }

      bool arabicNameMatches = false;
      if (arabicName is String) {
        arabicNameMatches = arabicName.toLowerCase().contains(_searchText.toLowerCase());
      }

      return nameMatches || arabicNameMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Quran'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Surah', 0),
                _buildTab('Juz', 1),
                _buildTab('Page', 2),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text('Error: $_error'))
                    : _filteredSurahs.isEmpty && _searchText.isEmpty
                        ? const Center(child: Text('No surahs found'))
                        : _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: _selectedTabIndex == index ? Colors.brown[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: _selectedTabIndex == index ? Colors.brown : Colors.black54,
              fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTabIndex) {
      case 0:
        return ListView.builder(
          itemCount: _filteredSurahs.length,
          itemBuilder: (context, index) {
            final surah = _filteredSurahs[index];
            return Column(
              children: [
                ListTile(
                  title: Text(surah['name'] ?? ''), // Use English name
                  subtitle: Text(surah['nameAr'] ?? ''), // Use Arabic name
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${surah['id'] ?? '-'}', style: TextStyle(color: Colors.white, fontSize: 12))), // Use surah ID for number
                  ),
                  onTap: () {
                    if (surah['id'] != null) {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahScreen(surahNumber: surah['id']), // Pass surah ID
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
              ],
            );
          },
        );
      case 1:
        return const Center(child: Text('Juz View (Coming Soon)')); // Placeholder for Juz view
      case 2:
        return const Center(child: Text('Page View (Coming Soon)')); // Placeholder for Page view
      default:
        return Container();
    }
  }
}
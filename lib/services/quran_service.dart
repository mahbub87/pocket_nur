import 'package:cloud_firestore/cloud_firestore.dart';

class QuranService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getSurah(int surahNumber) async {
    try {
      DocumentSnapshot surahDoc = await _firestore.collection('quran').doc(surahNumber.toString()).get();
      return surahDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting surah: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchAyahs(String query) async {
    try {
      // This is a basic search. For more advanced search, consider using a dedicated search service.
      QuerySnapshot querySnapshot = await _firestore.collection('quran').get();
      List<Map<String, dynamic>> results = [];

      for (var surahDoc in querySnapshot.docs) {
        Map<String, dynamic> surahData = surahDoc.data() as Map<String, dynamic>;
        if (surahData.containsKey('ayahs')) {
          List<dynamic> ayahs = surahData['ayahs'];
          for (var ayat in ayahs) {
            if (ayat.containsKey('translation') && ayat['translation'].toString().toLowerCase().contains(query.toLowerCase())) {
              results.add({'surah': surahDoc.id, ...ayat});
            }
          }
        }
      }
      return results;
    } catch (e) {
      print('Error searching ayahs: $e');
      return [];
    }
  }
}
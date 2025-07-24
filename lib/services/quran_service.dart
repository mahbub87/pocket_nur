import 'package:cloud_firestore/cloud_firestore.dart';

class QuranService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get metadata for all Surahs (no Ayahs included)
  Future<List<Map<String, dynamic>>> getAllSurahs() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('quran')
      .orderBy('id') // 👈 sort by id
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}


  /// Get metadata for one Surah (no Ayahs)
  Future<Map<String, dynamic>?> getSurah(int surahNumber) async {
    try {
      DocumentSnapshot surahDoc = await _firestore
          .collection('quran')
          .doc(surahNumber.toString())
          .get();
      return surahDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting surah: $e');
      return null;
    }
  }

  /// Get all Ayahs for a specific Surah
  Future<List<Map<String, dynamic>>> getAyahsForSurah(int surahNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('quran')
          .doc(surahNumber.toString())
          .collection('ayahs')
          .orderBy('id')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting ayahs for surah: $e');
      return [];
    }
  }

  /// Search through all Ayahs (translation field only)
  Future<List<Map<String, dynamic>>> searchAyahs(String query) async {
    final List<Map<String, dynamic>> results = [];

    try {
      final surahs = await _firestore.collection('quran').get();

      for (final surahDoc in surahs.docs) {
        final surahId = surahDoc.id;
        final ayahSnapshots = await _firestore
            .collection('quran')
            .doc(surahId)
            .collection('ayahs')
            .get();

        for (final ayahDoc in ayahSnapshots.docs) {
          final ayahData = ayahDoc.data();
          if ((ayahData['translation'] ?? '').toString().toLowerCase().contains(
            query.toLowerCase(),
          )) {
            results.add({'surah': surahId, ...ayahData});
          }
        }
      }

      return results;
    } catch (e) {
      print('Error searching ayahs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllJuz() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('juz')
      .orderBy('id') // 👈 sort by id
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}


  Future<List<Map<String, dynamic>>> getAllPages() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('pages')
      .orderBy('id') // 👈 sort by id
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}

}

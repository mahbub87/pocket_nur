const admin = require('firebase-admin');
const quranData = require('./quran.json');
const serviceAccount = require('../../pocket-nur-firebase-adminsdk-fbsvc-8367458b7b.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function uploadQuran() {
  for (const surah of quranData.surahs) {
    const surahRef = db.collection('quran').doc(surah.id.toString());
    await surahRef.set({ name: surah.name });

    for (const ayah of surah.ayas) {
      const ayahRef = surahRef.collection('ayahs').doc(ayah.aya.toString());
      await ayahRef.set({
        text: ayah.text,
        translation: ayah.translation,
        transliteration: ayah.transliteration,
        keywords: ayah.keywords,
        juz: ayah.juz,
        page: ayah.page,
      });
    }
  }
}

uploadQuran();

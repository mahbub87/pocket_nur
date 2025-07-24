const admin = require("firebase-admin");
const quranData = require("./quran.json");
const serviceAccount = require("../../pocket-nur-firebase-adminsdk-fbsvc-97667e4709.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true }); // Optional but recommended

function removeUndefined(obj) {
  return Object.fromEntries(
    Object.entries(obj).filter(([_, v]) => v !== undefined)
  );
}

async function uploadQuran() {
  for (const surah of quranData.surahs) {
    const surahRef = db.collection("quran").doc(surah.id.toString());

    await surahRef.set(
      removeUndefined({
        id: surah.id,
        name: surah.name,
        nameAr: surah.nameAr,
        nameTrans: surah.nameTrans,
        type: surah.type,
        order: surah.order,
        rukus: surah.rukus,
      })
    );

    for (const ayah of surah.ayas) {
      const ayahRef = surahRef.collection("ayahs").doc(ayah.aya.toString());
      await ayahRef.set(
        removeUndefined({
          id: ayah.aya,
          text: ayah.text,
          translation: ayah.translation,
          transliteration: ayah.transliteration,
          juz: ayah.juz,
          page: ayah.page,
          hizb: ayah.hizb,
          manzil: ayah.manzil,
          ruku: ayah.ruku,
          sajda: ayah.sajda,
          keywords: ayah.keywords,
        })
      );
    }
  }
}

uploadQuran()
  .then(() => {
    console.log("✅ Quran data uploaded successfully.");
  })
  .catch((err) => {
    console.error("❌ Error uploading Quran data:", err);
  });

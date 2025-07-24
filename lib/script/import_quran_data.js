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
async function uploadJuzAndPages() {
  const juzMap = new Map();
  const pageMap = new Map();

  for (const surah of quranData.surahs) {
    for (const ayah of surah.ayas) {
      const juzId = ayah.juz;
      const pageId = ayah.page;

      if (juzId) {
        if (!juzMap.has(juzId)) {
          juzMap.set(juzId, {
            id: juzId,
            startSurah: surah.name,
            startSurahId: surah.id,
            endSurah: surah.name,
            endSurahId: surah.id,
          });
        } else {
          juzMap.get(juzId).endSurah = surah.name;
          juzMap.get(juzId).endSurahId = surah.id;
        }
      }

      if (pageId) {
        if (!pageMap.has(pageId)) {
          pageMap.set(pageId, {
            id: pageId,
            surahName: surah.name,
            surahId: surah.id,
          });
        }
      }
    }
  }

  const juzRef = db.collection("juz");
  const pageRef = db.collection("pages");

  for (const juz of juzMap.values()) {
    await juzRef.doc(juz.id.toString()).set(juz);
  }

  for (const page of pageMap.values()) {
    await pageRef.doc(page.id.toString()).set(page);
  }

  console.log("Juz and pages uploaded successfully.");
}

async function main() {
  await uploadJuzAndPages();
}
main();

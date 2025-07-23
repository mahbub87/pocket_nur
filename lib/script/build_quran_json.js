const fs = require('fs');

// Load Quran text
const lines = fs.readFileSync('./quran-uthmani.txt', 'utf8').split('\n');
const ayat = lines
  .filter(line => line.trim())
  .map(line => {
    const parts = line.split('|');
    if (parts.length < 3) return null; // Skip malformed lines
    const [sura, aya, text] = parts;
    return {
      sura: Number(sura),
      aya: Number(aya),
      text: text ? text.trim() : ""
    };
  })
  .filter(a => a); // Remove nulls

// Load translation
const transLines = fs.readFileSync('./en.sahih.txt', 'utf8').split('\n');
const translationMap = {};
transLines.forEach(line => {
  const parts = line.split('|');
  if (parts.length < 3) return;
  const [sura, aya, text] = parts;
  translationMap[`${sura}|${aya}`] = text ? text.trim() : "";
});

// Load transliteration
const translitLines = fs.readFileSync('./en.transliteration.txt', 'utf8').split('\n');
const translitMap = {};
translitLines.forEach(line => {
  const parts = line.split('|');
  if (parts.length < 3) return;
  const [sura, aya, text] = parts;
  translitMap[`${sura}|${aya}`] = text ? text.trim() : "";
});

// Load metadata (copy-paste QuranData object from quran-data.js here)
const QuranData = require('./quran-data.js').QuranData;

// Helper: Find Juz, Page, Hizb, Manzil, Ruku for an ayah
function findMeta(metaArr, sura, aya) {
  let idx = 0;
  for (let i = 1; i < metaArr.length; i++) {
    const [msura, maya] = metaArr[i];
    if (sura > msura || (sura === msura && aya >= maya)) {
      idx = i;
    } else {
      break;
    }
  }
  return idx;
}

// Helper: Find Sajda type for an ayah
function findSajda(sura, aya) {
  for (let i = 1; i < QuranData.Sajda.length; i++) {
    const [ssura, saya, type] = QuranData.Sajda[i];
    if (ssura === sura && saya === aya) return type;
  }
  return null;
}

// Helper: Extract keywords from translation
function extractKeywords(translation) {
  return Array.from(
    new Set(
      translation
        .toLowerCase()
        .replace(/[^\w\s]/g, '') // Remove punctuation
        .split(/\s+/)
        .filter(Boolean)
    )
  );
}

// Build surah structure
const surahs = [];
for (let i = 1; i < QuranData.Sura.length; i++) {
  const meta = QuranData.Sura[i];
  if (!meta || meta.length < 8) continue;
  const [start, ayas, order, rukus, nameAr, nameEn, nameTrans, type] = meta;

  // Get ayat for this surah
  const surahAyat = [];
  for (let j = 1; j <= ayas; j++) {
    const ayahObj = ayat.find(a => a.sura === i && a.aya === j);
    if (!ayahObj) continue;

    // Add translation and transliteration
    const key = `${i}|${j}`;
    ayahObj.translation = translationMap[key] || "";
    ayahObj.transliteration = translitMap[key] || "";

    // Add meta data
    ayahObj.juz = findMeta(QuranData.Juz, i, j);
    ayahObj.page = findMeta(QuranData.Page, i, j);
    ayahObj.hizb = findMeta(QuranData.HizbQaurter, i, j);
    ayahObj.manzil = findMeta(QuranData.Manzil, i, j);
    ayahObj.ruku = findMeta(QuranData.Ruku, i, j);
    ayahObj.sajda = findSajda(i, j);

    // Add keywords for English search
    ayahObj.keywords = extractKeywords(ayahObj.translation);

    surahAyat.push(ayahObj);
  }

  surahs.push({
    id: i,
    name: nameEn,
    nameAr: nameAr,
    nameTrans: nameTrans,
    type: type,
    order: order,
    rukus: rukus,
    ayas: surahAyat
  });
}

// Save to JSON
fs.writeFileSync('./quran_structured.json', JSON.stringify({ surahs }, null, 2));
console.log('Quran structured data with translation, transliteration, and keywords saved!');
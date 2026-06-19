const fs = require("fs");
const path = require("path");

const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

const COLLECTION_NAME = "sky_days";

const jsonPath = path.join(
  __dirname,
  "../Lunora/Resources/astrology_data_2026_06_08.json"
);

async function deleteExistingSkyDays() {
  const snapshot = await db.collection(COLLECTION_NAME).get();

  if (snapshot.empty) {
    console.log("Silinecek eski sky_days verisi yok.");
    return;
  }

  let batch = db.batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;

    if (count % 400 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }

  await batch.commit();
  console.log(`${count} eski sky_days belgesi silindi.`);
}

async function uploadSkyDays() {
  console.log("Okunan JSON yolu:", jsonPath);

  const raw = fs.readFileSync(jsonPath, "utf8");
  const days = JSON.parse(raw);

  if (!Array.isArray(days)) {
    throw new Error("JSON dosyası direkt array formatında olmalı.");
  }

  let batch = db.batch();
  let count = 0;

  for (const day of days) {
    if (!day.date) {
      console.warn("date alanı olmayan kayıt atlandı:", day);
      continue;
    }

    const docRef = db.collection(COLLECTION_NAME).doc(day.date);

    batch.set(docRef, {
      ...day,
      source: "json_upload",
      updatedAt: FieldValue.serverTimestamp(),
    });

    count++;

    if (count % 400 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }

  await batch.commit();
  console.log(`${count} yeni sky_days belgesi yüklendi.`);
}

async function main() {
  console.log("Eski sky_days verileri siliniyor...");
  await deleteExistingSkyDays();

  console.log("Yeni gökyüzü verileri yükleniyor...");
  await uploadSkyDays();

  console.log("Tamamlandı.");
}

main().catch((error) => {
  console.error("Upload hatası:", error);
  process.exit(1);
});

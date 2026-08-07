import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const db = getFirestore();

export const deleteUserAccount = onCall(
    {
        region: "us-central1",
    },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError(
                "unauthenticated",
                "Hesabını silmek için giriş yapmalısın."
            );
        }

        try {
            const profileRef = db.collection("profiles").doc(uid);
            const profileSnapshot = await profileRef.get();
            const username = profileSnapshot.data()?.username;

            await db.recursiveDelete(
                db.collection("users").doc(uid)
            );

            await profileRef.delete();

            if (
                typeof username === "string" &&
                username.trim().length > 0
            ) {
                await db
                    .collection("usernames")
                    .doc(username)
                    .delete();
            }

            await getStorage()
                .bucket()
                .file(`profile_images/${uid}.jpg`)
                .delete({ ignoreNotFound: true });

            await getAuth().deleteUser(uid);

            return {
                success: true,
            };
        } catch (error) {
            console.error("Hesap silme hatası:", error);

            throw new HttpsError(
                "internal",
                "Hesap silinirken bir sorun oluştu."
            );
        }
    }
);

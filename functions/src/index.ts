import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import OpenAI from "openai";

initializeApp();

const db = getFirestore();
const openAiApiKey = defineSecret("OPENAI_API_KEY");

type DailyInsightResponse = {
    dateKey: string;
    title: string;
    subtitle: string;
    body: string;
    source: string;
};

type DailyInsightContext = {
    dateKey: string;
    userId: string;
    programName: string;
    programSummary: string;
    programElement: string;
    currentDay: number | null;
    durationDays: number | null;
    completedDaysCount: number | null;
    todayCompletionRate: number | null;
    currentStreak: number | null;
    moonSign: string;
    moonPhase: string;
    dailyComment: string;
    suitabilityScore: number | null;
    celestialEvents: string[];
    dailyTasksSummary: string;
    weeklyReflectionSummary: string;
    goldenRulesSummary: string;
    dailyPlanSummary: string;
    processResultSummary: string;
    hasActiveProgram: boolean;
    recommendedProgramsSummary: string;
    insightMode: "active_program" | "recommend_program" | "daily_practice";
};

export const generateDailyInsight = onCall(
    {
        region: "us-central1",
        invoker: "public",
        secrets: [openAiApiKey],
    },
    async (request): Promise<DailyInsightResponse> => {
        const authUserId = request.auth?.uid;

        const payloadUserId =
            typeof request.data?.userId === "string"
                ? request.data.userId
                : undefined;

        const userId = authUserId ?? payloadUserId;
        const dateKey = request.data?.dateKey as string | undefined;

        console.log("DailyInsight request data:", request.data);
        console.log("DailyInsight authUserId:", authUserId);
        console.log("DailyInsight payloadUserId:", payloadUserId);
        console.log("DailyInsight final userId:", userId);

        if (!userId) {
            throw new HttpsError(
                "unauthenticated",
                "Bu işlemi yapmak için kullanıcı girişi gerekli."
            );
        }

        if (!dateKey) {
            throw new HttpsError(
                "invalid-argument",
                "dateKey alanı zorunludur."
            );
        }

        const insightRef = db
            .collection("users")
            .doc(userId)
            .collection("dailyInsights")
            .doc(dateKey);

        const cachedDoc = await insightRef.get();

        if (cachedDoc.exists) {
            const cachedData = cachedDoc.data();

            return {
                dateKey,
                title: String(cachedData?.title ?? "İç sesine dön"),
                subtitle: String(cachedData?.subtitle ?? "Küçük adım da yeterli."),
                body: String(
                    cachedData?.body ??
                    "Bugün kendine yüklenmeden ilerlemen yeterli."
                ),
                source: String(cachedData?.source ?? "cache"),
            };
        }

        const context = await buildDailyInsightContext(userId, dateKey);

        let insight: DailyInsightResponse;

        try {
            insight = await generateOpenAIInsight(context);
        } catch (error) {
            console.error("OpenAI insight üretimi başarısız:", error);

            insight = {
                dateKey,
                title: "İç sesine dön",
                subtitle: "Küçük adım da yeterli.",
                body:
                    "Bugün kendine yüklenmeden ilerlemen yeterli. Bir görevi bilinçle tamamlamak bile yolculuğunu canlı tutar.",
                source: "fallback",
            };
        }

        await insightRef.set({
            ...insight,
            createdAt: FieldValue.serverTimestamp(),
            basedOn: {
                programName: context.programName,
                programElement: context.programElement,
                currentDay: context.currentDay,
                durationDays: context.durationDays,
                completedDaysCount: context.completedDaysCount,
                todayCompletionRate: context.todayCompletionRate,
                currentStreak: context.currentStreak,
                moonSign: context.moonSign,
                moonPhase: context.moonPhase,
                suitabilityScore: context.suitabilityScore,
                celestialEvents: context.celestialEvents,
            },
        });

        return insight;
    }
);

async function buildDailyInsightContext(
    userId: string,
    dateKey: string
): Promise<DailyInsightContext> {
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();
    const userData = userDoc.data() ?? {};

    const currentStreak =
        typeof userData.currentStreak === "number" ? userData.currentStreak : null;

    const activeEnrollmentId =
        typeof userData.activeEnrollmentId === "string"
            ? userData.activeEnrollmentId
            : null;
    const hasActiveProgram = activeEnrollmentId !== null;

    let programName = "Aktif program yok";
    let programSummary =
        "Kullanıcının bugün kendine daha şefkatli yaklaşmasını destekleyen genel bir Lunora yolculuğu.";
    let programElement = "belirsiz";
    let currentDay: number | null = null;
    let durationDays: number | null = null;
    let completedDaysCount: number | null = null;
    let todayCompletionRate: number | null = null;

    let dailyTasksSummary =
        "Bugün kullanıcıya küçük ve sürdürülebilir bir içsel pratik önerilir.";

    let weeklyReflectionSummary =
        "Haftalık değerlendirme bilgisi bulunamadı.";

    let goldenRulesSummary =
        "Kullanıcı süreci mükemmel yapmak zorunda değildir; küçük adımlar yeterlidir.";

    let dailyPlanSummary =
        "Günlük akış bilgisi bulunamadı.";

    let processResultSummary =
        "Süreç ilerledikçe kullanıcı kendi içsel değişimini daha net fark edebilir.";

    let recommendedProgramsSummary = "Önerilebilir aktif program bilgisi bulunamadı.";

    if (activeEnrollmentId) {
        const enrollmentRef = userRef
            .collection("program_enrollments")
            .doc(activeEnrollmentId);

        const enrollmentDoc = await enrollmentRef.get();
        const enrollmentData = enrollmentDoc.data() ?? {};

        const programId =
            typeof enrollmentData.programId === "string"
                ? enrollmentData.programId
                : null;

        currentDay =
            typeof enrollmentData.currentDay === "number"
                ? enrollmentData.currentDay
                : null;

        completedDaysCount =
            typeof enrollmentData.completedDaysCount === "number"
                ? enrollmentData.completedDaysCount
                : null;

        if (programId) {
            const programDoc = await db.collection("programs").doc(programId).get();
            const programData = programDoc.data() ?? {};

            programName =
                typeof programData.name === "string" ? programData.name : programName;

            programSummary =
                typeof programData.oneSentenceSummary === "string"
                    ? programData.oneSentenceSummary
                    : programSummary;

            programElement =
                typeof programData.elements === "string"
                    ? programData.elements
                    : programElement;

            durationDays =
                typeof programData.durationDays === "number"
                    ? programData.durationDays
                    : null;

            const dailyTasks = Array.isArray(programData.dailyTasks)
                ? programData.dailyTasks
                : [];

                dailyTasksSummary = summarizeDailyTasks(dailyTasks);

weeklyReflectionSummary = summarizeSection(programData.weeklyReflection);
goldenRulesSummary = summarizeSection(programData.goldenRules);
dailyPlanSummary = summarizeSection(programData.dailyPlanSummary);
processResultSummary = summarizeSection(programData.processResult);

            const todayLogDoc = await enrollmentRef
                .collection("dailyLogs")
                .doc(dateKey)
                .get();

            const todayLogData = todayLogDoc.data() ?? {};
            const completedTaskIds = Array.isArray(todayLogData.completedTaskIds)
                ? todayLogData.completedTaskIds
                : [];

            if (dailyTasks.length > 0) {
                todayCompletionRate = Math.round(
                    (completedTaskIds.length / dailyTasks.length) * 100
                );
            }
        }
    }

    if (!hasActiveProgram) {
    recommendedProgramsSummary = await buildRecommendedProgramsSummary();
}

    const skyDoc = await db.collection("sky_days").doc(dateKey).get();
    const skyData = skyDoc.data() ?? {};

    const celestialEvents = Array.isArray(skyData.celestial_events)
        ? skyData.celestial_events.map((item) => String(item))
        : [];

    const suitabilityScore =
    typeof skyData.suitability_score === "number"
        ? skyData.suitability_score
        : null;

const insightMode: "active_program" | "recommend_program" | "daily_practice" =
    hasActiveProgram
        ? "active_program"
        : suitabilityScore !== null && suitabilityScore >= 3
            ? "recommend_program"
            : "daily_practice";
    
    

    return {
        dateKey,
        userId,
        programName,
        programSummary,
        programElement,
        currentDay,
        durationDays,
        completedDaysCount,
        todayCompletionRate,
        currentStreak,
        dailyTasksSummary,
        weeklyReflectionSummary,
        goldenRulesSummary,
        dailyPlanSummary,
        processResultSummary,
        recommendedProgramsSummary,
        hasActiveProgram,
        insightMode,
        moonSign:
            typeof skyData.moon_sign === "string" ? skyData.moon_sign : "Bilinmiyor",
        moonPhase:
            typeof skyData.moon_phase === "string"
                ? skyData.moon_phase
                : "Bilinmiyor",
        dailyComment:
            typeof skyData.daily_comment === "string"
                ? skyData.daily_comment
                : "Bugünün gökyüzü verisi bulunamadı.",
        suitabilityScore,
        celestialEvents,
    };
}

async function generateOpenAIInsight(
    context: DailyInsightContext
): Promise<DailyInsightResponse> {
    const openai = new OpenAI({
        apiKey: openAiApiKey.value(),
    });

    const prompt = makePrompt(context);

    const response = await openai.responses.create({
        model: "gpt-4.1-mini",
        input: [
            {
                role: "system",
                content:
                    "Sen Lunora uygulaması için günlük içgörü üreten sakin, şefkatli ve ölçülü bir asistansın. Kişisel gelişim, spiritüel farkındalık, ezoterik sembol dili ve yogi bilgeliğinden ilham alırsın. Kehanet dili kullanmazsın. Tıbbi veya psikolojik teşhis koymazsın. Kullanıcıyı suçlamazsın. Yanıtın kısa, sade ve uygulama kartında gösterilmeye uygun olmalı.",
            },
            {
                role: "user",
                content: prompt,
            },
        ],
        text: {
            format: {
                type: "json_schema",
                name: "daily_insight",
                strict: true,
                schema: {
    type: "object",
    additionalProperties: false,
    properties: {
        title: {
            type: "string",
            description: "3-6 kelimelik kısa ve sakin başlık.",
        },
        subtitle: {
            type: "string",
            description: "Bugünün temasını özetleyen 1 kısa cümle.",
        },
        body: {
            type: "string",
            description: "4-6 kısa cümlelik, yaklaşık 450-700 karakterlik kişisel günlük rehberlik yorumu.",
        },
    },
    required: ["title", "subtitle", "body"],

                },
            },
        },
    });

    const outputText = response.output_text;

    if (!outputText) {
        throw new Error("OpenAI response output_text boş geldi.");
    }

    const parsed = JSON.parse(outputText) as {
        title?: string;
        subtitle?: string;
        body?: string;
    };

    return {
        dateKey: context.dateKey,
        title: cleanText(parsed.title, "İç sesine dön", 70),
        subtitle: cleanText(parsed.subtitle, "Küçük adım da yeterli.", 140),
        body: cleanText(
            parsed.body,
            "Bugün kendine yüklenmeden ilerlemen yeterli. Bir görevi bilinçle tamamlamak bile yolculuğunu canlı tutar.",
            700
        ),
        source: "openai",
    };
}

function makePrompt(context: DailyInsightContext): string {
    return `
Aşağıdaki verilere göre Profile ekranında gösterilecek kısa bir günlük içgörü üret.

Kullanıcı bağlamı:
- Aktif program: ${context.programName}
- Program elementi: ${context.programElement}
- Aktif program var mı?: ${context.hasActiveProgram ? "evet" : "hayır"}
- İçgörü modu: ${context.insightMode}
- Bugünün program görevleri:
${context.dailyTasksSummary}
- Önerilebilir programlar:
${context.recommendedProgramsSummary}

- Haftalık yansıma:
${context.weeklyReflectionSummary}

- Programın altın kuralları:
${context.goldenRulesSummary}

- Günlük akış özeti:
${context.dailyPlanSummary}

- Süreçte beklenen değişim:
${context.processResultSummary}
- Program günü: ${context.currentDay ?? "bilinmiyor"} / ${context.durationDays ?? "bilinmiyor"
        }
- Tamamlanan gün sayısı: ${context.completedDaysCount ?? "bilinmiyor"}
- Bugünkü görev tamamlama oranı: ${context.todayCompletionRate !== null
            ? `%${context.todayCompletionRate}`
            : "bilinmiyor"
        }
- Current streak: ${context.currentStreak ?? "bilinmiyor"}

Günlük gökyüzü:
- Ay burcu: ${context.moonSign}
- Ay fazı: ${context.moonPhase}
- Günlük yorum: ${context.dailyComment}
- Uygunluk skoru: ${context.suitabilityScore !== null
            ? `${context.suitabilityScore}/10`
            : "bilinmiyor"
        }
- Ek gökyüzü olayları: ${context.celestialEvents.length > 0
            ? context.celestialEvents.join(", ")
            : "yok"
        }

Yazım kuralları:
- Türkçe yaz.
- Programı ve gökyüzünü ayrı ayrı anlatma; tek bütünleşik yorum üret.
- Kullanıcıya bugün duymaya ihtiyaç duyabileceği şefkatli bir mesaj ver.
- Küçük bir adımı motive et.
- Kehanet gibi konuşma.
- "Kesin bugün şöyle olacak" deme.
- Tıbbi, psikolojik veya kesin kader iddiası kurma.
- Abartılı, klişe veya fazla mistik olma.
- title kısa ve etkileyici olsun; 3–6 kelimeyi geçmesin.
- subtitle 1 kısa cümle olsun; kullanıcının bugünkü temasını yumuşakça özetlesin.
- body 4–6 kısa cümleden oluşsun.
- body yaklaşık 450–700 karakter aralığında olsun.
- body içinde program adı, bugünün pratiği, programdaki ilerleme noktası ve gökyüzü teması doğal şekilde birleşsin.
- Bu yorum günün başında gösterilen bir rehberlik mesajıdır.
- Bugünkü görev tamamlama oranı düşük veya 0 olsa bile bundan bahsetme.
- “Henüz başlamadın”, “bugün hiçbir şey yapmadın”, “tamamlamadın” gibi eksiklik hissi veren ifadeler kullanma.
- Günlük görevlerden doğal şekilde ilham al.
- Mümkünse bugünün pratiğini yorumun içine yumuşakça dahil et.
- Kullanıcıya bugün bu görevleri yaparken hissedebileceği direnç, yavaşlık, dağınıklık veya hassasiyetin normal olabileceğini şefkatli şekilde söyle.
- Programın gün bilgisi ve toplam süresi biliniyorsa, önemli bir eşik varsa bunu doğal ve motive edici şekilde kullan.
- Eğer aktif program yoksa, mevcut program günü, görev tamamlama oranı veya mevcut program görevlerinden bahsetme.
- Eğer aktif program yoksa ve uygunluk skoru 3'ten küçükse, yeni programa başlamayı önermek yerine bugüne özel küçük bir farkındalık, nefes, yazı veya niyet pratiği öner.
- Eğer aktif program yoksa ve uygunluk skoru 3 veya üzerindeyse, önerilebilir programlar listesinden gökyüzü temasıyla en uyumlu bir programı seç ve nazikçe öner.
- Program önerirken baskılı konuşma; "başlamalısın", "yapmalısın" gibi zorlayıcı ifadeler kullanma.
- Uygunluk skoru düşükse "bugün uygun değil" gibi kesin konuşma; bunun yerine "bugün hazırlık yapmak daha yumuşak olabilir" gibi bir dil kullan.
- Aktif program yokken yorumun amacı kullanıcıya eksiklik hissettirmek değil, onu nazikçe uygun bir niyete veya programa yönlendirmektir.
- Eğer içgörü modu "recommend_program" ise, önerilebilir programlar listesinden kesinlikle 1 program seç ve body içinde programın adını aynen yaz.
- "recommend_program" modunda genel "Lunora yolculuğu" ifadesiyle yetinme; belirli bir program adı kullan.
- "recommend_program" modunda yorumun amacı, gökyüzünün desteklediği temaya göre kullanıcıyı tek bir programa nazikçe davet etmektir.
- Eğer içgörü modu "daily_practice" ise hiçbir program adı önerme; sadece bugüne özel küçük bir nefes, yazı, farkındalık veya niyet pratiği öner.
- Eğer içgörü modu "active_program" ise sadece kullanıcının mevcut aktif programına göre yorum yap.

`;

}

function cleanText(
    value: string | undefined,
    fallback: string,
    maxLength: number
): string {
    if (!value) {
        return fallback;
    }

    const cleaned = value.trim();

    if (!cleaned) {
        return fallback;
    }

    if (cleaned.length <= maxLength) {
        return cleaned;
    }

    return cleaned.slice(0, maxLength).trim();
}
function summarizeDailyTasks(tasks: unknown): string {
    if (!Array.isArray(tasks) || tasks.length === 0) {
        return "Günlük görev bilgisi bulunamadı.";
    }

    return tasks
        .map((task) => {
            const item = task as {
                title?: unknown;
                shortDescription?: unknown;
                details?: unknown;
            };

            const title =
                typeof item.title === "string" ? item.title : "Görev";

            const shortDescription =
                typeof item.shortDescription === "string"
                    ? item.shortDescription
                    : "";

            const details = Array.isArray(item.details)
                ? item.details.slice(0, 2).map((detail) => String(detail)).join("; ")
                : "";

            return `- ${title}: ${shortDescription}${details ? ` (${details})` : ""}`;
        })
        .join("\n");
}

function summarizeSection(section: unknown): string {
    if (!section || typeof section !== "object") {
        return "Bilgi bulunamadı.";
    }

    const item = section as {
        title?: unknown;
        shortDescription?: unknown;
        details?: unknown;
    };

    const title = typeof item.title === "string" ? item.title : "";
    const shortDescription =
        typeof item.shortDescription === "string" ? item.shortDescription : "";

    const details = Array.isArray(item.details)
        ? item.details.slice(0, 3).map((detail) => String(detail)).join("; ")
        : "";

    return [title, shortDescription, details].filter(Boolean).join(" - ");
}
async function buildRecommendedProgramsSummary(): Promise<string> {
    const snapshot = await db
        .collection("programs")
        .where("isActive", "==", true)
        .limit(10)
        .get();

    if (snapshot.empty) {
        return "Önerilebilir aktif program bulunamadı.";
    }

    return snapshot.docs
        .map((doc) => {
            const data = doc.data();

            const name =
                typeof data.name === "string" ? data.name : "İsimsiz program";

            const elements =
                typeof data.elements === "string"
                    ? data.elements
                    : "element bilgisi yok";

            const durationDays =
                typeof data.durationDays === "number"
                    ? `${data.durationDays} gün`
                    : "süre bilgisi yok";

            const summary =
                typeof data.oneSentenceSummary === "string"
                    ? data.oneSentenceSummary
                    : "Özet bilgisi yok.";

            return `- ${name} | Element: ${elements} | Süre: ${durationDays} | Özet: ${summary}`;
        })
        .join("\n");
}
export { deleteUserAccount } from "./deleteUserAccount";

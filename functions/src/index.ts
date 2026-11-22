import { createHash } from "node:crypto";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";

if (!getApps().length) initializeApp();

const db = getFirestore();
const NEWS_TOPIC = "fim_news_updates";
const HADITH_TOPIC = "fim_hadith_updates";
const ESD_URL = "https://esd.imi.gov.my/portal/latest-news/announcement/";
const HADITH_URL = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-bukhari.json";

interface UpdateItem {
  kind: "news" | "hadith";
  title: string;
  body: string;
  sourceUrl: string;
  reference?: string;
}

function stableId(item: UpdateItem): string {
  return createHash("sha256")
    .update(`${item.kind}|${item.title}|${item.sourceUrl}|${item.reference ?? ""}`)
    .digest("hex")
    .slice(0, 32);
}

async function fetchText(url: string): Promise<string> {
  const response = await fetch(url, {
    headers: { "user-agent": "FIM-Foreigner-in-Malaysia/2.22 (+official-updates)" },
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) throw new Error(`${url} returned HTTP ${response.status}`);
  return response.text();
}

function decodeHtml(value: string): string {
  return value
    .replace(/<[^>]+>/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;|&apos;/g, "'")
    .replace(/&nbsp;/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

async function getLatestEsdNews(): Promise<UpdateItem | null> {
  const html = await fetchText(ESD_URL);
  const links = [...html.matchAll(/<a[^>]+href=["']([^"']+)["'][^>]*>([\s\S]*?)<\/a>/gi)]
    .map((match) => ({ href: match[1], title: decodeHtml(match[2]) }))
    .filter((item) => item.title.length >= 12 && !/^(home|contact|login|read more)$/i.test(item.title));
  const candidate = links.find((item) => /announcement|notice|closure|myxpats|immigration|employment pass|permit/i.test(`${item.title} ${item.href}`)) ?? links[0];
  if (!candidate) return null;
  const sourceUrl = new URL(candidate.href, ESD_URL).toString();
  return {
    kind: "news",
    title: candidate.title.slice(0, 160),
    body: "Official ESD Online announcement. Open FIM to read the source notice.",
    sourceUrl,
  };
}

async function getDailyHadith(): Promise<UpdateItem> {
  const payload = JSON.parse(await fetchText(HADITH_URL)) as {
    metadata?: { name?: string };
    hadiths?: Array<{ hadithnumber?: string; text?: string }>;
  };
  const items = payload.hadiths ?? [];
  if (!items.length) throw new Error("Hadith API returned no items");
  const day = Math.floor(Date.now() / 86_400_000);
  const item = items[day % items.length];
  const text = (item.text ?? "").replace(/\s+/g, " ").trim();
  return {
    kind: "hadith",
    title: "Daily Hadith · Sahih al-Bukhari",
    body: text.length > 280 ? `${text.slice(0, 277)}...` : text,
    sourceUrl: HADITH_URL,
    reference: `Sahih al-Bukhari ${item.hadithnumber ?? ""}`.trim(),
  };
}

async function publishIfNew(item: UpdateItem, topic: string): Promise<boolean> {
  const id = stableId(item);
  const ref = db.collection("fim_daily_updates").doc(id);
  const existing = await ref.get();
  if (existing.exists) return false;
  await ref.set({ ...item, id, createdAt: FieldValue.serverTimestamp() });
  await getMessaging().send({
    topic,
    notification: { title: item.title, body: item.body },
    data: {
      kind: item.kind,
      sourceUrl: item.sourceUrl,
      reference: item.reference ?? "",
    },
    android: { priority: "high", notification: { channelId: "fim_daily_updates" } },
  });
  return true;
}

export const sendDailyFIMUpdates = onSchedule(
  {
    schedule: "0 9 * * *",
    timeZone: "Asia/Kuala_Lumpur",
    region: "asia-southeast1",
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async () => {
    const results = { news: "skipped", hadith: "skipped" };
    try {
      const news = await getLatestEsdNews();
      if (news) results.news = (await publishIfNew(news, NEWS_TOPIC)) ? "sent" : "duplicate";
    } catch (error) {
      logger.error("FIM official news update failed", error);
    }
    try {
      const hadith = await getDailyHadith();
      results.hadith = (await publishIfNew(hadith, HADITH_TOPIC)) ? "sent" : "duplicate";
    } catch (error) {
      logger.error("FIM daily Hadith update failed", error);
    }
    logger.info("FIM daily update run complete", results);
  },
);

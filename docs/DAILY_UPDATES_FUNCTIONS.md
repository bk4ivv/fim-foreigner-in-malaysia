# FIM daily news and Hadith notifications

The `functions/` directory contains the Firebase Cloud Function `sendDailyFIMUpdates`.

## What it does

- Runs every day at **09:00 Asia/Kuala_Lumpur** using Cloud Scheduler.
- Reads the official ESD Online announcements page:
  `https://esd.imi.gov.my/portal/latest-news/announcement/`
- Reads a daily item from the versioned Open Hadith API edition for Sahih al-Bukhari:
  `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-bukhari.json`
- Stores a hash-keyed record in the Firestore collection `fim_daily_updates`.
- Skips duplicates and sends only new items through FCM topics:
  - `fim_news_updates`
  - `fim_hadith_updates`
- Includes the source URL and Hadith reference in FCM data payloads.

The function does not invent a headline when a source fails. It logs the failure and does not send a fabricated notification.

## Deploy from a machine with Firebase CLI access

```bash
cd functions
npm install
npm run build
cd ..
npx firebase login
npx firebase use fim---foreigner-in-malaysia
npx firebase deploy --only functions:sendDailyFIMUpdates
```

The repository already contains `firebase.json` and `.firebaserc` for this project. Firebase Cloud Scheduler may require the Firebase/Google Cloud project to be upgraded from the no-cost Spark plan to Blaze. Confirm billing before deployment; no billing upgrade is performed by this code.

## App-side behavior

`FirebaseNotificationService.enableDailyUpdates(includeHadith: ...)` requests Android notification permission only after the user opts in, subscribes to the news topic, and subscribes to the Hadith topic only when the user selected Islam. `disableDailyUpdates()` unsubscribes from both topics.

The current app still needs a visible Settings toggle wired to these two methods before production release. Until that UI is added, the function can be deployed safely, but users will not be subscribed automatically.

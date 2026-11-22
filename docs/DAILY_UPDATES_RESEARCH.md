# Daily FIM updates

## Decision

FIM will use an opt-in daily update feed. The feed will refresh once per day from public sources and will be consumed by the app when it opens. Notifications will be scheduled only after the user enables them in Settings; the app will not silently request notification permission or send promotional spam.

## Foreign-worker sources

The primary source is the Malaysian Immigration Department foreign-worker service page. It contains official requirements, sectors, entry and post-arrival procedures, FOMEMA timing, VP(TE) extensions, fees and conditions. FIM must show the source date/link and must tell users to verify current requirements on the official page.

The expatriate-focused source is the Immigration Department's ESD Online announcement page. It publishes operational notices, MYXpats closures, MyIMMS disruptions, Professional Visit Pass guidance and employment-pass policy announcements. These notices are more suitable for daily alerts than third-party summaries.

ILO Malaysia migrant-worker material is a secondary context source only. It may be used for rights and safety explainers, but it must not be presented as a Malaysian government instruction.

## Hadith source

The open `fawazahmed0/hadith-api` repository exposes versioned JSON editions through jsDelivr, with multiple languages and grades. The app must retain the collection, book, hadith number and grade where available, and link to the source. Hadith content should be labelled with its collection/reference; FIM must not describe an item as universally authentic without preserving the collection's grading information.

The `hadithapi.com` service is also free but requires an API key, so it is not used as the default dependency for this app.

## Notification rules

- Daily updates are opt-in and can be disabled in Settings.
- Prayer alarms and daily news/Hadith notifications are separate switches.
- The first notification permission request happens only after the user enables a notification feature.
- A notification opens FIM's update feed; official source links remain available inside the app.
- If the feed cannot be refreshed, FIM uses the last cached item and does not fabricate a new headline.
- No employment, visa, immigration or religious notification is presented as professional/legal advice.

## Current implementation boundary

A scheduled GitHub feed refresh can update a JSON feed, but Android delivery while the app is closed requires a push provider such as Firebase Cloud Messaging or an equivalent notification service. Until that provider is configured, FIM can safely use local opt-in reminders and refresh content on app open. The app must not claim guaranteed real-time push delivery before that provider is connected.

## Sources

- Malaysian Immigration Department, Foreign Worker: https://www.imi.gov.my/index.php/en/main-services/foreign-worker/
- ESD Online announcements: https://esd.imi.gov.my/portal/latest-news/announcement/
- ILO Malaysia latest news: https://www.ilo.org/resource/other/malaysia-latest-news
- Open Hadith API repository: https://github.com/fawazahmed0/hadith-api
- Hadith API service documentation: https://hadithapi.com/

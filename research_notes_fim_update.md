# Research notes for FIM update

## Official and established transport booking sources

- redBus Malaysia: https://www.redbus.my/ — public page describes Malaysia bus booking across operators and routes, secure payment options, and online booking flow.
- Malaysia Airlines: https://www.malaysiaairlines.com/my/en/home.html — official Malaysia Airlines booking and travel site.
- BusOnlineTicket ferry booking: https://www.busonlineticket.com/booking/ferry-tickets.aspx — public page describes ferry booking for Malaysia/Singapore routes and lists operators/routes including Bluewater Express, Bistari Gemilang, Sindo Ferry, Batam Fast, Wantas RORO, and others.
- KTMB: https://www.ktmb.com.my/ — official KTM Berhad page with passenger service notices, ETS/KTM information, integrated ticket notices, and links to ticket-related services.

## Official Malaysian government sources

- Malaysian Immigration foreign-worker page: https://www.imi.gov.my/index.php/en/main-services/foreign-worker/ — describes permitted foreign-worker source countries, visa/VDR/VP(TE) procedures, FOMEMA timing, employment sectors, and government source attribution.
- Malaysian Ministry of Foreign Affairs overseas missions directory: https://www.kln.gov.my/web/guest/overseas-missions — public directory of Malaysia's missions by city and country; useful as an official diplomatic-directory fallback when an individual foreign mission page is unavailable.
- Foreign Missions in Malaysia page: https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia — identified by search as the intended official directory, but text extraction returned no content; verify through interactive browsing before relying on detailed fields.

## Implementation guardrails

Do not invent embassy phone numbers, social accounts, or country government URLs. For countries without a verified country-specific entry, show the official Malaysian diplomatic directory and explicitly label the entry as a directory/search route rather than pretending it is a direct embassy contact. Re-verify volatile links before release.

## v2.14 launcher verification

The preserved `assets/images/fim_malaysia_flag_logo.jpg` is a 512x512 circular Malaysian flag shield with navy field, yellow crescent/star, red-and-white stripes, and a light outline. The Android `mipmap-mdpi/ic_launcher.png` was visually checked after the scaffold repair and was still the default Flutter blue mark, so all Android density launcher icons must be regenerated from the preserved FIM shield before the final release package is made.

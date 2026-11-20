# FIM v2.21.4 — Prayer Reminders

**Version:** `2.21.4+56`
**Package ID:** `com.expatstatuschecker.expat_status_checker`
**Status:** Source and CI-verified; signed Play artifacts remain pending until the approved upload keystore is restored to GitHub Actions.

## Added

- Optional prayer-time reminders for Muslim users in Settings.
- Five daily reminders: Fajr, Dhuhr, Asr, Maghrib, and Isha.
- Editable reminder times, persisted with SharedPreferences.
- Android notification permission requested only when reminders are enabled.
- Malaysia timezone (`Asia/Kuala_Lumpur`) and reboot/package-update rescheduling support.
- English and Bangla notification titles and messages.

## Safety and scope

- FIM does not claim to calculate official prayer times locally. Users should verify the editable times against Malaysia’s official e-Solat timetable.
- Reminders use Android inexact-while-idle scheduling; the feature does not request special exact-alarm access.
- Choosing a non-Islam religion hides the prayer card and cancels existing FIM prayer reminders.
- The package ID remains unchanged and the version/build number is higher than the previous `2.21.3+55` release.

## Verification

- Latest source commit before this release bump: `7dacad53`.
- Flutter CI and test APK workflow passed on `7dacad53`.
- Release workflow run `44840037598` correctly stopped before compilation because the repository does not currently contain the required `FIM_UPLOAD_KEYSTORE_BASE64` and `FIM_KEY_PROPERTIES` Actions secrets.
- Do not upload a debug/test APK to Google Play. Build and verify a signed AAB with the approved upload certificate before submission.

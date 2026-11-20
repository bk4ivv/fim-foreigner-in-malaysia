# FIM — Next Manus Session Handoff

Repository: https://github.com/bk4ivv/fim-foreigner-in-malaysia.git

Current stable branch: `main`
Current direction: add the safe, guest-facing FIM Jobs & Groups portal while preserving the stable interface.

## Do not redo

Do not restore the Community tab. The project owner explicitly removed it. Do not replace the stable interface with a new redesign without a direct request.

## Immediate next work

1. Test the latest Flutter source and inspect the PDF-reported UI issues: drawer overflow, invisible dark-mode text/icons, creator profile contrast, and the learning-page notification behavior.
2. Keep FIM Jobs as a connection marketplace only: employers post jobs and job seekers contact employers directly. FIM must not act as recruiter, employer, placement agent, or visa/permit guarantor.
3. Preserve guest browsing and design optional secure accounts for job seekers and employers.
4. Keep the three Facebook groups visible in the FIM Jobs & Groups portal:
   - FIM-JOBS: https://www.facebook.com/share/g/1YPhM5ZtM4/
   - FIM-USERS: https://www.facebook.com/share/g/1CRjKBP3Jh/
   - Part Time Jobs Malaysia: https://www.facebook.com/share/g/18Rxk6goVa/

Planning details are in `docs/fim-jobs-community-plan.md`.

## Latest source status

The latest `main` contains the FIM Jobs & Groups portal, the three supplied Facebook group links, official MYFutureJobs and Immigration links, job-safety warnings, dynamic GitHub Actions artifact naming, and the compile fix recorded in `docs/RELEASE_NOTES_2.21.2.md`. Run Flutter analyze/test and the APK/AAB build in a Flutter-enabled environment before release. Push every source and documentation change to GitHub.

## v2.21.4 release state

The latest GitHub history after commit `5a89c86` adds optional Muslim prayer reminders through `f4661159` and its follow-up fixes through `7dacad53`. The feature is in Settings, supports Fajr, Dhuhr, Asr, Maghrib, and Isha, persists editable times, requests notification permission when enabled, and cancels reminders when a non-Islam religion is selected. The version bump is `2.21.4+56`; see `docs/RELEASE_NOTES_2.21.4.md` and `docs/PLAY_UPLOAD_CHECKLIST_2.21.4.md`.

The signed release workflow was dispatched as run `44840037598` but stopped before compilation because `FIM_UPLOAD_KEYSTORE_BASE64` and `FIM_KEY_PROPERTIES` are not configured in GitHub Actions. Never commit the keystore or passwords. Restore the approved upload keystore whose SHA-1 is `A7:A8:41:45:97:6A:D1:BD:7A:3E:EB:A0:8B:FF:A8:67:9D:07:F7:52`, configure those two secrets, then rerun the workflow and verify the AAB certificate before Play upload.

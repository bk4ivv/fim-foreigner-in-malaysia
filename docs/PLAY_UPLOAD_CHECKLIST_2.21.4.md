# FIM v2.21.4 Play Console upload checklist

Use this release only after the signed artifacts have been built with the approved upload key.

| Field | Value |
|---|---|
| App | FIM - Foreigner in Malaysia |
| Version name | `2.21.4` |
| Version code | `56` |
| Package ID | `com.expatstatuschecker.expat_status_checker` |
| Previous version | `2.21.3` / version code `55` |
| Approved upload SHA-1 | `A7:A8:41:45:97:6A:D1:BD:7A:3E:EB:A0:8B:FF:A8:67:9D:07:F7:52` |
| Required primary upload | Signed Android App Bundle (`.aab`) |
| Optional upload/test file | Signed universal release APK (`.apk`) |

## Short release note

Optional prayer reminders are now available for Muslim users. Set and edit five daily prayer times in Settings, receive repeating notifications in English or Bangla, and verify times against Malaysia’s official e-Solat timetable. We also improved Android notification and reboot handling.

## Before uploading

1. Confirm the AAB package is exactly `com.expatstatuschecker.expat_status_checker`.
2. Confirm version name `2.21.4` and version code `56`; never upload an older code than `55`.
3. Confirm the signing certificate SHA-1 matches the approved upload certificate above.
4. Confirm the SHA-256 values from the generated `SHA256SUMS.txt` file.
5. Upload the AAB in Play Console. Keep the APK for device testing or fallback verification; do not use the debug/test APK for production.

## Current blocker

The repository release workflow is ready, but the required private keystore has not been configured as the GitHub Actions secrets `FIM_UPLOAD_KEYSTORE_BASE64` and `FIM_KEY_PROPERTIES`. The private keystore cannot be reconstructed from a SHA-1 fingerprint. Restore the original approved upload keystore and its passwords, then rerun `.github/workflows/build-release.yml`.

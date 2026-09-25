# FIM Play Store Release Handoff

**App:** FIM – Foreigner in Malaysia
**Package ID:** `com.expatstatuschecker.expat_status_checker`
**Version:** `2.15.1`
**Version code:** `39`
**Change:** Replaced the app and Android launcher branding with the supplied transparent FIM logo.

## Release artifacts

The Play Store upload must be a **release-signed Android App Bundle** (`.aab`). A release APK is useful for direct device testing, but Google Play should receive the AAB. The upload key must be the same key registered for the existing Play Console app; do not generate a replacement key unless the Play Console owner has completed the key-reset process.

The source tree contains no private keystore, passwords, or `android/key.properties` by design. Configure those locally or in a protected CI secret store before making a production release build.

## Build commands

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Expected outputs:

```text
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

## Pre-upload checklist

- Confirm the Play Console package ID is `com.expatstatuschecker.expat_status_checker`.
- Confirm the upload key matches the existing app’s signing setup.
- Test the release APK on a physical Android device.
- Verify the app launches, language selection works, official-service links open, QR scanning works, and external web content behaves as expected.
- Review the Play Console **Data safety** form against the current privacy behavior and third-party SDKs.
- Review the content rating, target audience, app access, store listing, screenshots, privacy-policy URL, and support email.
- Upload the AAB to an internal or closed test track before production rollout.
- Increase version code for every later upload; never reuse `39`.

## Important signing note

A new signing certificate cannot update an already-installed Play Store app signed with a different certificate. Preserve the original upload/organization credentials securely and do not commit them to GitHub.

## Release notes

> Updated the FIM logo across the app and Android launcher. This release also improves brand consistency for future FIM updates.

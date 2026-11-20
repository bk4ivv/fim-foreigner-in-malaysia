# FIM Release Audit — 2026-11-21

## Verified external requirements

Google Play's current target API guidance says that from August 31, 2026, new apps and app updates must target Android 16 / API level 36 or higher. Source: https://developer.android.com/google/play/requirements/target-sdk

Google Play uses Android App Bundles to generate optimized APKs for device configurations, and new Play publishing should use an AAB rather than treating a debug APK as the release artifact. Source: https://developer.android.com/guide/app-bundle

Android release signing requires a signed upload artifact. With Play App Signing, Google protects the app signing key while the developer keeps an upload key; private keys and passwords must remain secret and must not be committed to GitHub. Public certificates/fingerprints may be shared when needed. Source: https://developer.android.com/studio/publish/app-signing

## Repository state at audit start

The complete GitHub `main` branch was restored from https://github.com/bk4ivv/fim-foreigner-in-malaysia.git at commit `5a89c86` (`feat: add FIM Jobs and trusted groups portal`). The repo contains 105 tracked files and the working tree was clean at restoration.

The sandbox has Java 21 but no Flutter or Dart SDK, so local Flutter analyze/test/APK/AAB execution is not currently available. GitHub Actions has previously built a debug test APK successfully, but the Flutter CI workflow failed because the widget tests were stale: one test still expected a `Community` bottom-navigation destination even though that destination was intentionally removed, and another expected `MYFutureJobs` before navigating into the FIM Jobs & Groups page. The launch-progress test also failed and needs a stable testable completion condition.

## Known source issues to address

- Update stale widget tests to match the current three-destination shell and FIM Jobs & Groups portal.
- Make launch/loading progress deterministic and testable, without indefinite waiting.
- Audit all asset references and logo placement. Keep FIM-TM for launcher assets and FIM-T for in-app transparent branding; avoid mixing service logos with the app mark.
- Audit WebView link routing and avoid accidental browser fallback unless explicitly intended.
- Add Google Mobile Ads only with test ad unit IDs and consent/privacy configuration; do not place production ad IDs or force ads into user actions until the Play policy setup is complete.
- Confirm Android target API 36 or higher before Play submission. The current Gradle config delegates `compileSdk` and `targetSdk` to Flutter, so the Flutter toolchain version must be verified before release.
- Release builds require a local `android/key.properties` and upload keystore. These are intentionally excluded from version control.

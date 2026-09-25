# FIM 2.15.1 build artifact status

## Built and available for device testing

- `app-debug.apk`: built successfully with Flutter 3.47.5, Android SDK, and Java 21. This is debug-signed and is **not** suitable for Play Console upload.
- `app-debug.aab`: built successfully with Flutter 3.47.5, Android SDK, and Java 21. This is a debug build and is **not** the production Play Store bundle.

## Production release status

A release build was attempted and intentionally stopped by the project’s signing guard:

```text
Release signing requires android/key.properties.
```

The repository does not contain the private upload keystore or passwords. This is required to prevent accidentally creating an artifact that cannot update the existing Play Store application. Create `android/key.properties` locally using the existing Play upload key, then run the commands in `PLAY_STORE_RELEASE_HANDOFF.md`.

## Verification performed

- `flutter analyze`: no issues found.
- `flutter test`: 20 tests passed.
- Debug APK build: passed.
- Debug AAB build: passed.
- New logo: RGBA with transparent corners; canonical source is `assets/images/fim_logo.png`.
- Source branch backup: `feat/update-fim-logo` on GitHub.

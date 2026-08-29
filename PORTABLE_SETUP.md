# Foreigner in Malaysia — Portable Flutter Source

This package contains the complete Flutter source used to build **Foreigner in Malaysia**, including the Android project, Dart application code, bundled country/language/currency data, official service logos, learning-library assets, widget tests, and the startup/WebView reliability fixes.

## What is included

| Area | Included content |
|---|---|
| Flutter app | `lib/`, `pubspec.yaml`, assets, tests, and project configuration |
| Android | `android/` Gradle project and launcher assets |
| Data | Country, language, currency, learning, and holiday data |
| Branding | User-supplied shield logo prepared for in-app and launcher use |
| Validation | `test/widget_test.dart` and the project’s analysis configuration |

Generated caches, build output, local SDK paths, local machine configuration, private signing keys, and private credentials are intentionally excluded. The optional community backend file is included as a safe template and does not contain the previous project’s credentials.

## Recommended environment

Use Flutter 3.47.0 or a compatible recent Flutter 3 release with Dart 3.13 or newer. Android builds require Android Studio or the Android command-line tools, an Android SDK with the project’s compile SDK installed, and a Java Development Kit. Java 21 was used for the validated build. The project can be opened in Android Studio or Visual Studio Code on Windows, macOS, or Linux.

## Open and run the project

Extract the ZIP, open a terminal in the extracted project folder, and run:

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run
```

Connect an Android phone with developer mode and USB debugging enabled, or start an Android emulator before running `flutter run`. The first Gradle build may take several minutes while dependencies are downloaded.

## Build an Android APK

For a normal release APK, run:

```bash
flutter build apk --release --build-name=2.12.4 --build-number=33
```

The output will be created at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For a Play Store upload, create or recover the correct private keystore, configure `android/key.properties` locally, and add the signing configuration to the Android Gradle project. Do not put the keystore, passwords, or `key.properties` into a public repository or send them through an unencrypted channel. The original production keystore from the previous build is not included in this package.

## Optional community backend

The core app is offline-first and does not contact Supabase during startup. The file `lib/community_backend_config.dart` uses compile-time placeholders. If you intentionally restore the optional community screens, provide your own values at build time, for example:

```bash
flutter build apk --release \
  --dart-define=COMMUNITY_SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=COMMUNITY_SUPABASE_PUBLISHABLE_KEY=your-publishable-key \
  --dart-define=COMMUNITY_EMAIL_REDIRECT_URL=foreignworkermalaysia://login
```

Use only a Supabase publishable/anonymous client key in a mobile app. Never embed a service-role key in Flutter code.

## iPhone and App Store note

This package is currently prepared around the Android project. To produce an iOS project, use a Mac with Xcode installed and run `flutter create --platforms=ios .` in a copy of the project, then review the iOS permission strings and signing settings. iOS distribution requires an Apple Developer account and Apple signing certificates.

## Troubleshooting

If the app appears to remain on a loading page, confirm that the country-currency dataset is present in `pubspec.yaml`, then run `flutter clean`, `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter run` again. The current source includes the v2.11.0-style country-selection flow and a visible retry state if bundled data fails to load. Official websites are shown in the in-app WebView. If an official site does not respond within the bounded loading period, the app now shows retry and browser-fallback actions rather than leaving an indefinite spinner.

## Source integrity

The source package is provided so you can inspect, modify, or rebuild the application in another Flutter environment. It is not a replacement for the original production signing key: a new signature cannot update an APK already installed with a different signing certificate.

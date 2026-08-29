# FIM - Foreigner in Malaysia

**FIM - Foreigner in Malaysia** is a Flutter Android utility app for foreign workers and expats in Malaysia. It provides country-first onboarding, national-language or English selection, official Malaysian service links, learning content, emergency/help information, travel tools, exchange-rate routing, QR and translation tools, and a creator information section.

The current source preserves the smooth v2.11.0-style country-selection flow while retaining the newer FIM branding, Malaysian flag color themes, official service cards, learning library, Trips section, and unified Help & info destination. The country-selection data includes the required country, language, and currency assets, and the loader has an explicit retry state rather than an indefinite spinner.

## Quick start

Use Flutter 3.47.0 or a compatible recent Flutter 3 release, Dart 3.13 or newer, Android Studio or the Android SDK command-line tools, and Java 21 or a compatible JDK.

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run
```

Build the current Android release APK with:

```bash
flutter build apk --release --build-name=2.12.4 --build-number=33
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Important security notes

This repository intentionally excludes private signing keys, passwords, `.env` files, SDKs, caches, generated build output, and release APKs. The original production keystore is not part of this source package. Keep any Play Store signing material in a secure local or CI secret store.

The optional community backend configuration is safe to customize with a Supabase URL and publishable client key. Never place a Supabase service-role key in a mobile application or public repository. See `PORTABLE_SETUP.md` for the optional configuration pattern and iOS conversion notes.

## Project layout

| Directory | Purpose |
|---|---|
| `lib/` | Flutter application source, screens, navigation, localization, and services |
| `assets/data/` | Country, language, currency, holiday, and learning datasets |
| `assets/images/` | App logo and official service imagery |
| `android/` | Android Gradle project and launcher resources |
| `test/` | Widget and data-contract regression tests |
| `PORTABLE_SETUP.md` | Detailed setup, build, security, and troubleshooting guide |

## License and official links

Review the applicable terms for every external official website before redistributing linked content. This project is a utility interface and does not replace Malaysian government or employer decisions about work authorization, immigration, medical clearance, or employment status.

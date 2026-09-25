# FIM 2.15.1 release manifest

| Field | Value |
|---|---|
| Version name | `2.15.1` |
| Version code | `39` |
| Android application ID | `com.expatstatuschecker.expat_status_checker` |
| Canonical logo | `assets/images/fim_logo.png` |
| Launcher resources | `android/app/src/main/res/mipmap-*/ic_launcher.png` |
| Release type | Branding/logo update |
| Required Play artifact | Release-signed `.aab` |
| Optional testing artifact | Release-signed `.apk` |

## Files changed

- `assets/images/fim_logo.png`: supplied transparent FIM logo.
- `lib/main.dart`: shared in-app branding points to the canonical logo.
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: regenerated launcher sizes.
- `pubspec.yaml`: version incremented to `2.15.1+39`.
- `tools/prepare_fim_logo.py`: repeatable asset preparation script.

## Verification record

The logo source and generated PNGs must be checked for RGBA mode, transparent outer corners, and expected dimensions. Run Flutter analysis and tests in a Flutter-enabled environment before uploading to Play Console. This sandbox does not contain the Flutter SDK or private release keystore.

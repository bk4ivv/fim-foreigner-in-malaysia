

## v2.19 Information Architecture, Saved Preferences, and Games

- [x] Remove the bottom navigation bar from the worker utility shell.
- [x] Reorganize the home screen into category-level cards instead of individual tool tiles.
- [x] Keep tickets together in a unified ticket hub, including movie/events and bus/plane/ferry/train travel paths.
- [x] Add a Settings & privacy screen as the only in-app route for changing country and language after onboarding.
- [x] Persist the selected country and language so the app reuses them until the user changes them.
- [x] Add offline instant-play Quick Tap and Memory Match games.
- [x] Document the compliant AdMob/consent/frequency-cap setup; production ad IDs are intentionally not guessed or committed.
- [ ] Run Flutter pub get, analyzer, tests, and signed release build in an environment with Flutter SDK installed.


## v2.21.0 Premium Opening Surface
- [x] Replace the crowded first screen with a personalized Home Dashboard.
- [x] Add navy/cyan/white/yellow premium visual hierarchy.
- [x] Add weather and selected-country greeting card.
- [x] Add four priority actions: Government, Money Manager, Malaysia Map, and Prayer Times.
- [x] Move secondary actions into a horizontal Quick Tools row.
- [x] Remove the bottom navigation bar from the opening shell.
- [x] Restore the FIM menu button in the top app bar.
- [x] Keep FIM-T as the in-app logo and FIM-TM as the launcher identity.
- [x] Bump test version to 2.21.0 (build 52).
- [ ] Run Flutter pub get, analyzer, tests, and APK build in GitHub Actions.


## v2.21.1 Overflow Fix
The drawer menu cards and premium Home priority cards now use explicit responsive heights instead of restrictive aspect ratios. This prevents Bangla and other large-script subtitles from overflowing at the bottom on smaller screens and with increased system text size. Test version is 2.21.1, build 53.

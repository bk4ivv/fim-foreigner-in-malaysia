# FIM monetization setup

## Current implementation

- The Games area contains offline instant-play games and does not block gameplay behind an ad.
- The UI describes FIM as free and leaves space for consent-based advertising.
- No production AdMob IDs are committed to the repository.

## Why production ads are not hard-coded yet

A production AdMob integration requires the owner's AdMob account, Android app ID, ad-unit IDs, privacy/consent configuration, and confirmation that the Play Console Data safety answers match the actual SDK behavior. Using guessed IDs or forcing an ad on every click can result in invalid traffic, poor retention, or Play policy issues.

## Recommended compliant flow

1. Create the FIM Android app in AdMob and obtain the app ID and ad-unit IDs.
2. Add Google UMP consent handling for users in applicable regions before requesting ads.
3. Use a banner only on the Games landing page or a clearly labelled sponsored area.
4. Use an interstitial only at a natural break, such as after a completed game round, with frequency caps.
5. Use rewarded ads only when the user explicitly chooses an optional reward; never disguise the close button or block essential app features.
6. Update the Play Console Data safety form and privacy policy to disclose ad SDK data collection and personalization choices.
7. Test with Google test ad units first, then switch to production IDs only after release verification.

The next build environment should run `flutter pub get`, `flutter analyze`, and a release build after the real IDs and consent settings are supplied.

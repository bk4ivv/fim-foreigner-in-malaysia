# FIM v2.21.2 — Build and Testing Notes

**Recorded:** 2026-11-09
**Repository:** https://github.com/bk4ivv/fim-foreigner-in-malaysia
**Source branch:** `main`
**Source commit:** `e42c4dc`
**Version:** `2.21.2+54`

## Build fix recorded

The GitHub Actions Flutter build initially failed because a theme-dependent color expression was used inside a `const Icon`:

```dart
color: scheme.primary
```

The icon was changed from `const Icon` to a runtime `Icon`. This is the minimal compile fix; it does not change the visual behavior or navigation behavior of the app.

## Verification

- GitHub Actions workflow: `Build FIM test APK`
- Successful workflow run: `42524051428`
- Workflow commit: `e42c4dc`
- APK build: successful
- APK artifact: `FIM-Foreigner-in-Malaysia-v2.21.2-build54-test.apk`
- Artifact URL: https://github.com/bk4ivv/fim-foreigner-in-malaysia/actions/runs/42524051428/artifacts/13634658033

## Important release status

This is a device-testing APK from the GitHub Actions workflow. It is not yet a Google Play production release. Before publishing to Play Console, run the full Flutter test/analyze checks, create the signed release APK/AAB with the approved upload key, verify the package ID and version code, and create a release tag.

## Next planned direction

Continue step by step from the stable latest source. FIM Jobs remains planning-first: guest browsing, direct employer/job-seeker contact, moderation, scam warnings, optional accounts, and no recruitment-agency or visa-guarantee claims. Every future source or documentation change must be tested where possible and pushed to GitHub immediately.

# FIM v2.21.3 — Jobs & Groups Update

**Version:** `2.21.3+55`
**Status:** Device-testing build; not a Play production release until signed release artifacts are verified.

## Added

- New **FIM Jobs & Groups** portal accessible from the FIM drawer.
- Direct links to the three project-supplied Facebook groups:
  - FIM-JOBS🇲🇾
  - FIM-USERS♾️
  - Part Time Jobs Malaysia
- Official links to MYFutureJobs and Malaysia Immigration foreign-worker information.
- Bilingual English/Bangla labels and descriptions for the portal.
- Job-safety warning covering advance-payment scams, passport surrender, OTP/bank-password requests, illegal work, and guaranteed visa/job claims.

## Preserved

- Community tab remains removed as directed; the new portal is a separate Jobs & Groups destination.
- Guest browsing remains available.
- FIM does not act as a recruiter, employer, placement agent, or visa/permit guarantor.
- Stable FIM interface, latest FIM-TM branding, dark-mode fixes, weather utilities, Money Manager, tickets, map, games, and official-service tools remain in place.

## Build and backup

- GitHub Actions test APK workflow now derives the artifact filename from `pubspec.yaml`, avoiding stale version/build names.
- Every source, test, workflow, and note change in this update is committed to `main` before release validation.
- Before Play submission: run Flutter analyze/test, create signed APK/AAB with the approved upload key, verify package ID and version code, and tag the release.

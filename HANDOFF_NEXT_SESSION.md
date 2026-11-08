# FIM — Next Manus Session Handoff

Repository: https://github.com/bk4ivv/fim-foreigner-in-malaysia.git

Current stable branch: `main`
Current commit: `2f718c6` — remove Community tab, repair drawer overflow, and fix creator profile dark-mode contrast.

## Do not redo

Do not restore the Community tab. The project owner explicitly removed it. Do not start a redesign or build without a direct request.

## Immediate next work

1. Test the latest Flutter source and inspect the PDF-reported UI issues: drawer overflow, invisible dark-mode text/icons, creator profile contrast, and the learning-page notification behavior.
2. Plan FIM Jobs as a connection marketplace only: employers post jobs and job seekers contact employers directly. FIM must not act as recruiter, employer, placement agent, or visa/permit guarantor.
3. Preserve guest browsing and design optional secure accounts for job seekers and employers.
4. Keep the three Facebook groups as future links:
   - FIM-JOBS: https://www.facebook.com/share/g/1YPhM5ZtM4/
   - FIM-USERS: https://www.facebook.com/share/g/1CRjKBP3Jh/
   - Part Time Jobs Malaysia: https://www.facebook.com/share/g/18Rxk6goVa/

Planning details are in `docs/fim-jobs-community-plan.md`.

## Latest source status

The latest `main` is pushed and clean. This sandbox does not currently have the Flutter SDK, so Flutter analyze/test/APK build could not be run here; run them in a Flutter-enabled environment before release.

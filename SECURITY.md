# Security Policy

## Scope

This policy covers the Foreigner in Malaysia Flutter application and the source repository. The app is designed to start offline using bundled data. Optional community features and third-party official-service websites have their own service policies and are not controlled by this project.

## Supported version

The current release line is **2.15.0+38**. Security fixes are applied to the current release line when practical. Users should update to the latest published build.

## Reporting a vulnerability

Please report suspected vulnerabilities privately to the project maintainer through the private security-reporting channel configured for the repository. Do not publish exploit details, credentials, personal data, keystores, or proof-of-concept payloads in a public issue. Include the affected version, device/Android version, reproduction steps, expected and observed behavior, and any minimal evidence needed to validate the report.

The maintainer will acknowledge a report when received, investigate its impact and reproducibility, and coordinate a fix or mitigation before public disclosure where possible. Reports that are not security vulnerabilities, including general feature requests and ordinary support questions, should use the project’s normal issue or support channels.

## Credential and signing handling

The repository must never contain Android keystores, `android/key.properties`, signing passwords, API keys, Supabase service-role keys, or other production credentials. Release signing is performed with private files kept outside Git and passwords supplied by environment variables or a secure CI secret store.

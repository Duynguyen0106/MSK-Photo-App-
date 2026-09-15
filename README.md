# MSK Suite

Two Flutter apps sharing one core package for musculoskeletal check-in and clinical documentation.

## Repository layout

```
packages/msk_core/   — shared services (no UI)
apps/patient/        — consumer-facing check-in app (6-screen flow)
apps/clinician/      — clinical measurement & documentation tool
```

## Safety rules (both apps)

- Findings are **observations** only — never diagnoses or treatment advice.
- Every health-data screen shows a disclaimer.
- Red-flag symptoms trigger urgent-care messaging.
- Photos are processed on-device; never uploaded without explicit consent.

## Getting started

Requires Flutter stable (3.24+).

```bash
# Core package
cd packages/msk_core && flutter pub get && flutter test

# Patient app
cd apps/patient && flutter pub get && flutter run

# Clinician app
cd apps/clinician && flutter pub get && flutter run
```

## Patient app

Plain-language, 6-screen flow: Welcome → Symptoms → Capture (photo + manual fallback) → Processing → Results → Summary.

## Clinician app

Multi-patient encrypted local roster, pose landmarks, angle measurements, L/R deltas, confidence scores, PDF/CSV export.

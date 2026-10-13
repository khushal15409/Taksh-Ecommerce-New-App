# CI / CD

## Workflow

**File:** `.github/workflows/build-release-apk.yml`  
**Name:** Build Release APK

### Triggers

- Push to `main`, `staging`, `master`
- Pull request targeting those branches
- Manual `workflow_dispatch`

### Environment

| Tool | Version |
|------|---------|
| Runner | `ubuntu-latest` |
| Java | 17 (Zulu) + Gradle cache |
| Flutter | **3.38.5** stable (`subosito/flutter-action@v2`) |

### Steps

1. Checkout  
2. Setup Java + Flutter  
3. `flutter pub get`  
4. `dart run build_runner build --delete-conflicting-outputs`  
5. `flutter build apk --release`  
6. Read version from `pubspec.yaml`  
7. Rename APK → `taksh-ecommerce-v{version}-{timestamp}.apk`  
8. Upload artifact `release-apk` (retention 30 days)  
9. **On push to `main` only:** create GitHub Release with the APK (`softprops/action-gh-release`)

### Not run in CI (today)

- `flutter test`
- `flutter analyze`
- Flavor-specific entry points (`main_dev` vs `main`) — release APK uses default `lib/main.dart` entry unless build args change
- Signing config documentation beyond standard Flutter release setup (ensure local `key.properties` / secrets for Play Store outside this workflow as needed)

---

## Local parity

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

Match Flutter version to CI when debugging CI-only failures.

---

## Release checklist (manual)

1. Bump `version:` in `pubspec.yaml`  
2. Ensure codegen + l10n clean  
3. Smoke-test mock + dev against API  
4. Merge to `main` (or run workflow_dispatch)  
5. Download artifact / GitHub Release APK  
6. Verify Razorpay **live** keys are backend-issued for production payments  

---

## Related

- [DEVELOPMENT.md](DEVELOPMENT.md)  
- [AGENTS.md](../AGENTS.md)

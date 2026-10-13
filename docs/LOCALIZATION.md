# Localization (i18n)

| Item | Value |
|------|--------|
| Config | `l10n.yaml` |
| ARB dir | `lib/l10n/` |
| Template | `app_en.arb` |
| Languages | **English (`en`)**, **Hindi (`hi`)** |
| Output | `app_localizations.dart` (generated) |
| Runtime locale | Driven by `SplashCubit` |

`pubspec.yaml` has `flutter: generate: true` and depends on `flutter_localizations` + `intl`.

---

## Commands

```bash
# After editing ARB files
flutter gen-l10n
```

Access in widgets:

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.someKey);
```

---

## Adding a string

1. Add key to `lib/l10n/app_en.arb` (template — required).  
2. Add the same key to `lib/l10n/app_hi.arb`.  
3. Run `flutter gen-l10n`.  
4. Use `AppLocalizations.of(context)!.yourKey` — never hard-code user-facing English in widgets.

**Parity note:** Hindi ARB has historically been shorter than English. When adding features, keep keys in sync. Helper scripts `compare_arb.dart` / `compare_arb.py` at repo root can help diff keys.

---

## Changing language at runtime

`SplashCubit` exposes locale updates used by root `BlocBuilder` → `MaterialApp.router(locale: ...)`.

Home includes a language toggle widget (`language_fluid_toggle.dart`).

`AppConstants.supportedLocales` lists locale constants; the app Material localizations use bare `en` / `hi` from generated localizations.

---

## Rules

- All user-visible copy → ARB  
- Validators that show messages should take `AppLocalizations` or pre-resolved strings  
- Do not commit hand-edited generated l10n Dart if your workflow regenerates on build — follow team practice; generated files may exist in tree depending on `generate: true`  

---

## Related

- [DEVELOPMENT.md](DEVELOPMENT.md)  
- [features/SPLASH_AND_ONBOARDING.md](features/SPLASH_AND_ONBOARDING.md)

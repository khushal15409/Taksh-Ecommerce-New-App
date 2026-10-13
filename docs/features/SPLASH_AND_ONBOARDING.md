# Feature: Splash & Onboarding

**Paths:**  
- `lib/features/splash/`  
- `lib/features/onboarding/`  

**Historical docs (enhanced, not deleted):**  
[SPLASH_CUBIT_ARCHITECTURE.md](../SPLASH_CUBIT_ARCHITECTURE.md) · [SPLASH_IMPLEMENTATION.md](../SPLASH_IMPLEMENTATION.md)

---

## Current state (source of truth)

### SplashCubit (singleton)

Registered lazy singleton; provided at app root.

Responsibilities today:

- Coordinate startup initialization (min display duration, parallel tasks)  
- **Locale** for `MaterialApp`  
- **ThemeMode** (light/dark)  
- Location permission helpers / current location cache  
- Optional home prefetch hooks  

UI: `SplashPage` listens to SplashCubit **and** AuthBloc, then navigates when ready.

### Navigation after splash (current product behavior)

Guests are allowed into the **home shell** (not forced to login). Login is demanded by guards / GuestAuthWall for protected actions.

Onboarding shows on first launch (SharedPreferences flag) before or around first home entry as implemented in router/splash coordination.

### Onboarding

Presentation-only carousel (`OnboardingPage`) with illustration assets. Marks completion in prefs so it does not repeat.

---

## What changed vs early SPLASH_IMPLEMENTATION.md

The early doc described:

- Simple demo login  
- `isLoggedIn` SharedPreferences flag only  
- Force login after splash  

That prototype path is **obsolete**. Real auth uses `AuthBloc` + SecureStore tokens. Prefer this file + SPLASH_CUBIT_ARCHITECTURE for design, and AUTH.md for session rules.

---

## When updating

- Keep SplashCubit lightweight — heavy API prefetch should use feature repos explicitly.  
- Locale/theme persistence: document storage keys if you add them.  
- Do not block entire app on location permission; allow skip (permission docs cover UI patterns).

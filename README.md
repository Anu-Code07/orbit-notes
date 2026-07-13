# Orbit Notes

Local-first travel journal for Flutter — trips, days, entries, photos, and map pins.

## First launch

1. **Login / Sign up first** — on a fresh install Orbit opens the auth screens (`/login`, with a link to `/signup`). You can also tap **Continue offline**.
2. **One example trip** — after you reach home, Orbit seeds a single sample journal titled **Example · Kyoto Spring**, tagged **EXAMPLE**. It teaches the Trip → Day → Entry flow and is safe to delete (swipe left).
3. **Interactive tour** — [`showcaseview`](https://pub.dev/packages/showcaseview) walks through **New trip**, the example card, and **Sign in / Sync** so new users learn how the app works.

## Alpha scope

- **Trip → day → entry** hierarchy with Clean Architecture + BLoC
- Clay-inspired cream canvas, saturated accent cards
- OpenStreetMap pins via `flutter_map` (no API key)
- Local photos copied into app documents
- Offline Drift/SQLite persistence
- Email + Google auth via Supabase, local↔cloud sync
- Aesthetic login/signup with frosted forms
- First-run education via `showcaseview`

## Run

```bash
flutter pub get
dart run build_runner build
flutter run
```

Cloud setup: see `docs/SUPABASE_SETUP.md`.

To re-test first launch locally, clear app data (or uninstall) so SharedPreferences resets the auth gate + home tour flags.

## Architecture

```
lib/
  core/           theme, DI, prefs, failures, shared widgets, Supabase config
  features/auth/  login, signup, AuthBloc
  features/notes/
    domain/       entities, repository contract, use cases
    data/         Drift DB + repository + cloud sync
    presentation/ BLoC + pages + widgets
```

UI talks only to BLoC → use cases → repository.

## Design tokens

Clay tokens live in `lib/core/theme/` — use `context.colors` / theme extensions, not inline hex.

## Branding

Launcher icon and splash assets live in `assets/branding/`.

Regenerate after changing them:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Splash uses Clay canvas `#fffaf0` with the Orbit mark centered.

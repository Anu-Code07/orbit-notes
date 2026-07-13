# Orbit Notes

Local-first travel journal for Flutter — trips, days, entries, photos, and map pins.

## Alpha scope

- **Trip → day → entry** hierarchy with Clean Architecture + BLoC
- Clay-inspired cream canvas, saturated accent cards, Inter display type
- Full-bleed trip covers with parallax collapse
- OpenStreetMap pins via `flutter_map` (no API key)
- Local photos copied into app documents
- Offline Drift/SQLite persistence
- Demo trips seeded on first launch

**Also included:** email + Google auth via Supabase, local↔cloud sync, aesthetic login/signup.

## Run

```bash
flutter pub get
dart run build_runner build
flutter run
```

Cloud setup: see `docs/SUPABASE_SETUP.md`.

## Architecture

```
lib/
  core/           theme, DI, failures, shared widgets, Supabase config
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

# Orbit Notes

Local-first travel journal for Flutter.  
**Trip → Day → Entry** — with photos, map pins, GPS, and optional cloud sync.

<p align="center">
  <img src="docs/screenshots/login.png" width="220" alt="Orbit login screen" />
  &nbsp;
  <img src="docs/screenshots/home.png" width="220" alt="Orbit home journals" />
  &nbsp;
  <img src="docs/screenshots/trip-detail.png" width="220" alt="Orbit trip detail" />
</p>

<p align="center">
  <em>Login · Home journals · Trip map, gallery & day timeline</em>
</p>

---

## What it is

Orbit is a cream Clay-inspired journal for collecting days on the road. Notes stay on device by default; sign in when you want them in the cloud.

| | |
|---|---|
| **Offline first** | Drift / SQLite + local photo files |
| **Places** | OpenStreetMap pins + one-shot GPS |
| **Auth** | Email/password + Google via Supabase |
| **Education** | First-run login gate + `showcaseview` tour |

---

## Screens

### Login / Sign up (first launch)

On a fresh install, Orbit opens auth before the atlas.

- Email + password, or **Continue with Google**
- **Create an account** for signup
- **Continue offline** if you want to journal without an account

<img src="docs/screenshots/login.png" width="280" alt="Welcome back login" />

### Home — journals

Brand-first home with **New trip**, **Sign in / Sync**, and tilted trip cards.

<img src="docs/screenshots/home.png" width="280" alt="Orbit home with trip cards" />

### Trip detail — map, gallery, timeline

Map with pin count, photo gallery (“Scattered frames”), and a day-by-day timeline with entries and **Write this day**.

<img src="docs/screenshots/trip-detail.png" width="280" alt="Trip detail with map and timeline" />

---

## First launch flow

1. **Auth gate** — `/login` (link to `/signup`) or Continue offline. Remembered via SharedPreferences.
2. **Example trip** — one sample journal (**Example · Kyoto Spring**) tagged **EXAMPLE**. Open it to learn Trip → Day → Entry; **swipe left to delete** when you no longer need it.
3. **Interactive tour** — [`showcaseview`](https://pub.dev/packages/showcaseview) highlights **New trip**, the example card, and **Sign in / Sync**.

To re-test first launch: clear app data or uninstall so prefs (auth gate + tour) reset. Wipe the DB if you still have older demo trips.

---

## Features

- Trip → day → entry hierarchy (Clean Architecture + BLoC)
- Clay cream UI, frosted glass, orbit backdrops
- Full-bleed covers, day rail timeline, photo frames
- Map pins via `flutter_map` (no Maps API key)
- **Use GPS** or drop a pin manually on an entry
- Local photos in app documents
- Email + Google auth, bidirectional sync when signed in
- First-run education with `showcaseview`

---

## Run

```bash
flutter pub get
dart run build_runner build
flutter run
```

Supabase / Google OAuth setup: [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md)

```bash
# Optional overrides
flutter run \
  --dart-define=SUPABASE_URL=https://….supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_… \
  --dart-define=GOOGLE_WEB_CLIENT_ID=….apps.googleusercontent.com
```

Never commit the Google **client secret** — dashboard only.

---

## Release build

Single source of truth: [`release.json`](release.json)  
(app IDs, version `1.0.0+1`, Android/iOS commands, env notes, changelog, screenshots).

```bash
# APK + App Bundle (recommended)
./scripts/build_release.sh

# Or manually
flutter build apk --release
flutter build appbundle --release
```

The script writes `.dart_defines.release.json` from `release.json` → `dart_defines` and passes version via `--build-name` / `--build-number`.

Tag `v1.0.0` (or Actions → Release → Run workflow) to build on GitHub via [`.github/workflows/release.yml`](.github/workflows/release.yml).

Bump `version` in `pubspec.yaml` and `release.json` → `app` together before shipping.

---

## Architecture

```
lib/
  core/           theme, DI, prefs, location, Supabase config, shared widgets
  features/auth/  login, signup, AuthBloc
  features/notes/
    domain/       entities, repository, use cases
    data/         Drift DB, repository, cloud sync
    presentation/ BLoC, pages, widgets
```

UI → BLoC → UseCase → Repository. Models stay out of the UI.

---

## Stack

| Layer | Choice |
|--------|--------|
| UI | Flutter, `go_router`, Clay tokens |
| State | `flutter_bloc` + GetIt |
| Local | Drift / SQLite, `path_provider` |
| Maps | `flutter_map` + OSM |
| GPS | `geolocator` (on-demand only) |
| Auth / cloud | `supabase_flutter`, `google_sign_in` |
| Tour | `showcaseview` |

---

## Branding

Assets in `assets/branding/`. Splash canvas `#fffaf0`.

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## License

Private project — see repository settings.

# Supabase setup — Orbit Notes (`oyjxpiradbbuocxsunmu`)

Cursor’s Supabase MCP is linked to a **different** project. Apply these steps in the dashboard for **`oyjxpiradbbuocxsunmu`**.

## 1. SQL + storage

In **SQL Editor**, paste and run:

`supabase/migrations/20260713170000_orbit_notes.sql`

## 2. Auth providers

**Authentication → Providers**

1. Enable **Email** (password).
2. Enable **Google**.
3. Paste:
   - **Client ID:** `245020475764-jhbmje6n9sm636bkta903fr053aj13qt.apps.googleusercontent.com`
   - **Client Secret:** from Google Cloud Console (the `GOCSPX-…` value).  
     Do **not** put the secret in the Flutter app or git.

## 3. Redirect URLs

**Authentication → URL Configuration** — add:

- `io.supabase.orbitnotes://login-callback/`

**Google Cloud Console → OAuth client → Authorized redirect URIs** — add:

- `https://oyjxpiradbbuocxsunmu.supabase.co/auth/v1/callback`

For Android Google Sign-In, also create an **Android** OAuth client with package `com.orbit.orbit_notes` and your SHA-1. Keep the **Web** client ID as the one above (app uses it as `serverClientId`).

**iOS:** Orbit uses Supabase browser OAuth (`io.supabase.orbitnotes://login-callback/`) by default, so a Web client is enough. For native Google Sign-In on iOS, create an **iOS** OAuth client with bundle ID `com.orbit.orbitNotes`, then pass:

- `--dart-define=GOOGLE_IOS_CLIENT_ID=….apps.googleusercontent.com`
- Add that client’s **iOS URL scheme** (`com.googleusercontent.apps.…`) under `CFBundleURLSchemes` in `ios/Runner/Info.plist`

## 4. Run the app

```bash
flutter run
```

Optional overrides:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://oyjxpiradbbuocxsunmu.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_… \
  --dart-define=GOOGLE_WEB_CLIENT_ID=245020475764-….apps.googleusercontent.com
```

## 5. AI trip planner (Groq via Edge Function)

The Flutter app calls Supabase Function **`plan-trip`**. The Groq key never ships in the app.

### Set the secret (dashboard or CLI)

**Dashboard:** Project Settings → Edge Functions → Secrets → add:

- `GROQ_API_KEY` = your `gsk_…` key  
- optional: `GROQ_MODEL` = `llama-3.3-70b-versatile`

**CLI:**

```bash
supabase login
supabase link --project-ref oyjxpiradbbuocxsunmu
supabase secrets set GROQ_API_KEY=gsk_your_key_here
supabase functions deploy plan-trip
```

Function source: `supabase/functions/plan-trip/`.

### App usage

Home → **Plan** → Weave this trip. The app invokes `plan-trip` with the user’s Supabase session (or anon key).

**Local fallback:** if `plan-trip` is not deployed yet (404), the app falls back to a local Groq call when `lib/core/config/groq_secrets.dart` has a key (gitignored — copy from `groq_secrets.example.dart`).

## Security

- Client ID + publishable/anon key: OK in the app.
- Google **client secret**: dashboard only.
- Groq **API key**: Supabase Edge Function secret only — never in git or the Flutter binary.

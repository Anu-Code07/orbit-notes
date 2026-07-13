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

## Security

- Client ID + publishable/anon key: OK in the app.
- Google **client secret**: dashboard only. If it was pasted in chat, rotate it in Google Cloud and update Supabase.

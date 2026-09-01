# Whimsical Hub

Flutter web app + Dart API. Catalog and orders live in **MongoDB Atlas**. Owner dashboard at `/dashboard`, public shop at `/shop/<slug>`.

## Local

1. Copy `.env.example` to `.env` and fill Atlas + owner credentials.
2. Allow your IP (or `0.0.0.0/0`) in Atlas **Network Access**.
3. Start the API (loads `MONGODB_URI` from the environment):

```bash
cd server
# PowerShell: Get-Content ../.env | ForEach-Object { ... }  or set vars manually
dart pub get
dart run bin/server.dart
```

4. Run the app against that API:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --dart-define=API_URL=http://localhost:8080
```

On first boot the server runs idempotent migrations: indexes, then seeds the owner (`OWNER_EMAIL` / `OWNER_PASSWORD`) and four sample products if the database is empty.

`flutter run` in debug (no `API_URL`) uses in-memory sample data so the UI works without Atlas. To use Mongo locally, run the server and pass `API_URL=http://localhost:8080`.

## Render

The Docker image builds Flutter web, compiles the Dart API, and serves both on `$PORT`. On startup it connects to Atlas (with retries) and applies any pending rows in `schema_migrations`.

Set at least:

- `MONGODB_URI`
- `JWT_SECRET`
- `OWNER_EMAIL`
- `OWNER_PASSWORD`

Atlas → Network Access must allow Render (`0.0.0.0/0` is simplest). Flutter web is built with an empty `API_URL` so the browser calls `/api` on the same host. Deep links (`/shop/:slug`, `/dashboard/*`) fall back to `index.html`.

## iPhone / iPad

The owner app (add products, orders, share link) is a real iOS app. Customers do **not** need it — they open the shop URL in Safari.

### Customers (no install)

After Render is live, share:

`https://YOUR-APP.onrender.com/shop/whimsical`

On iPhone: Safari → Share → **Add to Home Screen** for an app-like shop.

### Owner app

On iPhone the app opens the **dashboard**. Sign in with `OWNER_EMAIL` / `OWNER_PASSWORD`. Home → copy/share your shop link (Messages, Instagram, etc.).

The iOS build talks to MongoDB through your live site. Bake that URL in:

```bash
flutter build ipa --release \
  --dart-define=API_URL=https://YOUR-APP.onrender.com \
  --dart-define=PUBLIC_BASE_URL=https://YOUR-APP.onrender.com
```

That command needs a **Mac** and an **Apple Developer** account ($99/year) to sign an `.ipa` you can send (TestFlight, or Ad Hoc for listed devices). An unsigned file will not install on a normal iPhone.

This PC is Windows, so it cannot compile an iPhone install file here. Until you have a signed IPA:

1. Deploy the web app to Render
2. On the owner’s iPhone, open `https://YOUR-APP.onrender.com/dashboard` in Safari
3. Share → **Add to Home Screen**
4. Log in, add products, tap Share on the shop link

### Android file you can send from Windows

```bash
flutter build apk --release \
  --dart-define=API_URL=https://YOUR-APP.onrender.com \
  --dart-define=PUBLIC_BASE_URL=https://YOUR-APP.onrender.com
```

The APK is `build/app/outputs/flutter-apk/app-release.apk`.

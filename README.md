# hydRate (mobile)

Flutter app for finding, rating, and contributing water fountains and bathrooms.
Backend: [hydrate-backend](https://github.com/awesomeaiden/hydrate-backend).

Android application ID: `dev.aidengonzalez.hydrate`

## Setup

1. Install Flutter (stable, 3.47+), a JDK 17, and the Android SDK.
2. Copy `.env.example` to `.env` and set `BACKEND_API_URL` (no trailing slash).
   The Android emulator reaches a backend on your machine at `http://10.0.2.2:3000`.
3. `flutter pub get`

## Run / test

```
flutter run
flutter analyze
flutter test
```

## Release builds (Google Play)

Release builds are signed with an *upload key* read from `android/key.properties`,
which is gitignored and must never be committed:

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Create a keystore with:

```
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Keep the keystore and its password backed up somewhere safe. With Play App Signing
enabled (the default for new apps), Google holds the actual app signing key, so a lost
upload key can be reset through Play Console support, but that takes time.

If `key.properties` is missing, release builds fall back to the debug key (fine for local
testing, but rejected by Play).

Build the bundle to upload to Play, pointing it at the production backend:

```
flutter build appbundle --release --dart-define=BACKEND_API_URL=https://YOUR_API_HOST
# -> build/app/outputs/bundle/release/app-release.aab
```

`--dart-define=BACKEND_API_URL` overrides the value in `.env` (which still has to exist, since
it's bundled as an asset).

Bump `version:` in `pubspec.yaml` (the `+N` build number must increase) for every upload.

## Maps

Map tiles come from the free OpenStreetMap tile servers. Their
[usage policy](https://operations.osmfoundation.org/policies/tiles/) requires a real user
agent and visible attribution, both handled in `lib/src/custom_widgets/osm_map_layers.dart`.
If usage ever grows past what the policy allows, swap the `urlTemplate` for a hosted tile
provider.

## Localization

Strings live in `lib/src/localization/*.arb`. `flutter pub get` / `flutter run` regenerate
`app_localizations*.dart` next to them.

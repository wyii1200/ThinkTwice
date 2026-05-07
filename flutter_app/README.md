# ThinkTwice Flutter

## Google Maps setup

The Smart Radar screen already uses `google_maps_flutter`, but you still need to add your own API keys:

### Android

Edit:

`android/app/src/main/res/values/google_maps_api.xml`

Replace:

`REPLACE_WITH_ANDROID_GOOGLE_MAPS_API_KEY`

with your real Android Maps SDK key.

### iOS

Edit:

`ios/Runner/Info.plist`

Replace:

`REPLACE_WITH_IOS_GOOGLE_MAPS_API_KEY`

with your real iOS Maps SDK key.

### Web

Edit:

`web/index.html`

Replace:

`REPLACE_WITH_WEB_GOOGLE_MAPS_API_KEY`

with your real Maps JavaScript API key.

## Run

```bash
flutter pub get
flutter run
```

## Notes

- The Radar screen asks for location permission through `geolocator`.
- If permission is granted, the map centers on the user's location.
- If permission is denied, the app falls back to the default Petaling Jaya camera.
- If you run on Chrome or Edge, the web Google Maps key in `web/index.html` must be set or the map will fail to load.

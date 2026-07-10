# TRAVIS

TRAVIS (Trans Padang Vehicle and Information System) Mobile Application.

## RUNNING LOCAL

### Development API (RUN USING ANDROID STUDIO BUTTON WILL USE THIS ENV)
```shell
flutter run --dart-define=ENV=DEV 
```

### Production API

```shell
flutter run --dart-define=ENV=PROD
```

## BUILD APK

### Development API
```shell
flutter build apk --release --tree-shake-icons --dart-define=ENV=DEV
```

### Production API
```shell
flutter build apk --release --tree-shake-icons --dart-define=ENV=PROD
```

## BUILD AAB (APP BUNDLE) -> IN CASE NEED TO UP FOR PLAYSTORE
```shell
flutter build appbundle --release --tree-shake-icons --dart-define=ENV=PROD
```
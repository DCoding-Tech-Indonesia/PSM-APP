# psm_mobile

PSM Mobile Application.

## RUNNING LOCAL

### Development API
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
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

### Development API (DEBUG MODE) -> Only for development purpose. HIGH SECURITY RISK IF USE ON PRODUCTION APP
```shell
flutter build apk --release --tree-shake-icons --dart-define=ENV=DEV --dart-define=NETWORK_LOGGER_ENABLED=true
```

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

## NETWORK TRACER
1. On first running, you can see log like this
```
I/flutter (24145): 🚀 NetworkLogWebServer: Starting server on 0.0.0.0:3000...
I/flutter (24145): ✅ NetworkLogWebServer: Server started successfully!
I/flutter (24145): 🌐 Network Logger Dashboard: http://xx.x.x.x:3000 (emulator) or http://YOUR_MAC_IP:3000 (physical device)
I/flutter (24145): ccmni1 -> xx.x.xxx.xx
I/flutter (24145): ccmni1 -> xxxx:xx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxxxxx
I/flutter (24145): wlan0 -> xxx.xxx.x.xx
I/flutter (24145): wlan0 -> xxxx:xx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxxxxx
I/flutter (24145): wlan0 -> xxxx:xx:xxxx:xxxx:xxxx:xxx:xxxx:xxxxxx
I/flutter (24145): ccmni2 -> xxxx:xx:xxxx:xxx:x:x:xxxx:xxxxxxx
```
2. If you running locally, just open url showed as (emulator)
3. If you running on real device, use wlan0 + ":3000" to open logger dashboard
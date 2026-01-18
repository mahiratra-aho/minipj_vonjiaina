# vonjiaina_front
Application Flutter pour VONJIAINA - Trouvez vos médicaments rapidement.

Votre santé, plus proche que jamais

## Technologies utilisées

Flutter - Framework mobile multiplateforme (Dart)
Provider / Riverpod - Gestion d'état
Dio - Client HTTP pour les appels API
Google Maps Flutter - Affichage de cartes interactives
Geolocator - Géolocalisation
Shared Preferences - Stockage local

## Installation
- Prérequis

Flutter SDK >= 3.0 (Installation)
Dart SDK (inclus avec Flutter)
Android Studio (pour Android)
Xcode (pour iOS, macOS uniquement)
Un appareil ou émulateur configuré

Vérification avec : flutter doctor

## Dépendances principales
dans pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
    provider: ^6.1.1
  http: ^1.1.2
  geolocator: ^14.0.2
  permission_handler: ^12.0.1
  url_launcher: ^6.2.2
  intl: ^0.20.2
  logging: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
## Installer les dépendances
flutter pub get

## Note importante sur l'URL API :

Émulateur Android : http://10.0.2.2:8000
Simulateur iOS : http://localhost:8000
Appareil physique (web) : http://localhost:8000

## Lancement
flutter run -d <device_id>

- utile : 

Hot Reload (r) : Recharge le code sans perdre l'état de l'app
Hot Restart (R) : Redémarre l'app complètement
Quit (q) : Quitter

## Build (pas encore conseiller)
flutter build apk --release
flutter build ios --release

## Support
Pour toute question ou problème consultez la documentation Flutter

class AppConstants {
  // App Info
  static const String appName = 'VonjiAIna';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Trouvez vos médicaments facilement';

  // Localisation
  static const double defaultLatitude = -18.9137; // Antananarivo
  static const double defaultLongitude = 47.5236;
  static const double defaultSearchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km

  // Timeouts
  static const int splashDuration = 5; // secondes
  static const int locationTimeout = 10; // secondes

  // Pagination
  static const int itemsPerPage = 20;

  // Messages
  static const String noInternetMessage = 'Pas de connexion internet';
  static const String locationErrorMessage = 'Erreur de localisation';
  static const String serverErrorMessage = 'Erreur serveur, veuillez réessayer';

  // Format
  static const String distanceUnit = 'km';
  static const String priceUnit = 'Ar';

  // Google Maps
  static String getGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }

  // Appel téléphonique
  static String getPhoneUrl(String phoneNumber) {
    return 'tel:$phoneNumber';
  }
}

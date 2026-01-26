import 'dart:math';

class LocationHelper {
  static const double _earthRadiusKm = 6371.0;

  /// Calcule la distance en kilomètres entre deux points GPS
  /// en utilisant la formule de Haversine
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Convertit les degrés en radians
  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Formate la distance pour l'affichage
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
}

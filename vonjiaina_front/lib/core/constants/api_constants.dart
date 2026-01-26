class ApiConstants {
  // Pour device physique sur même réseau : 'http://192.168.1.XXX:8001'
  // Pour développement local : 'http://10.0.2.2:8001' (émulateur Android)
  static const String baseUrl = 'http://192.168.1.110:8001';
  // Pour iOS simulator: 'http://localhost:8001'

  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String searchPharmacies = '$apiVersion/pharmacies/search';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 150);
  static const Duration receiveTimeout = Duration(
      seconds:
          150); //les duration sont à diminuer sur emulateur mais juste pour tester
}

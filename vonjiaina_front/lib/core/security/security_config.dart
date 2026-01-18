/// Configuration centralisée de la sécurité pour VonjiAIna
/// Ce fichier contient tous les paramètres de sécurité configurables
class SecurityConfig {
  // Configuration de l'API d'audit
  static const String auditApiDevUrl = 'http://localhost:3000';
  static const String auditApiProdUrl = 'https://api.vonjiaina.mg';

  // Configuration des certificats SSL
  static const List<String> allowedSslFingerprints = [
    // Remplacer par le fingerprint de votre certificat SSL
    '87:15:95:F6:B4:66:1C:EA:67:E6:A1:66:94:F1:23:B9:C6:22:21:9A:7D:61:12:A8:39:01:5B:6D:D6:87:6C:30', // Google.com
    '00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00', // Développement
  ];

  // Configuration des timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Configuration des tentatives de sécurité
  static const int maxFailedAttempts = 20;
  static const int criticalFailedAttempts = 50;
  static const Duration lockdownDuration = Duration(minutes: 30);

  // Configuration des clés de chiffrement
  static const int pbkdf2Iterations = 100000;
  static const int saltLength = 32;
  static const int keyLength = 32;

  // Vérification si on est en développement
  static bool get isDevelopment =>
      bool.fromEnvironment('dart.vm.product') == false;

  // URL de l'API d'audit selon l'environnement
  static String get auditApiUrl =>
      isDevelopment ? auditApiDevUrl : auditApiProdUrl;
}

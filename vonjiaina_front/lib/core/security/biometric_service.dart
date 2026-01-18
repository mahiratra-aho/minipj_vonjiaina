import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';

enum BiometricAvailability {
  available,
  notAvailable,
  notEnrolled,
  deviceNotSupported,
}

class BiometricService {
  static final Logger _logger = Logger('BiometricService');
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<BiometricAvailability> checkAvailability() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return BiometricAvailability.deviceNotSupported;
      }

      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) {
        return BiometricAvailability.deviceNotSupported;
      }

      final availableBiometrics = await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } catch (e) {
      _logger.severe('Erreur vérification disponibilité biométrie', e);
      return BiometricAvailability.notAvailable;
    }
  }

  static Future<List<String>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      List<String> types = [];

      for (var biometric in availableBiometrics) {
        switch (biometric) {
          case BiometricType.fingerprint:
            types.add('Empreinte digitale');
            break;
          case BiometricType.face:
            types.add('Reconnaissance faciale');
            break;
          case BiometricType.iris:
            types.add('Reconnaissance iris');
            break;
          case BiometricType.strong:
            types.add('Biométrie forte');
            break;
          case BiometricType.weak:
            types.add('Biométrie faible');
            break;
        }
      }

      return types;
    } catch (e) {
      _logger.severe('Erreur récupération types biométriques', e);
      return [];
    }
  }

  static Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool biometricOnly = false,
  }) async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      _logger.info(
          'Authentification biométrique: ${isAuthenticated ? 'succès' : 'échec'}');
      return isAuthenticated;
    } on PlatformException catch (e) {
      _logger.warning(
          'Erreur authentification biométrique: ${e.code} - ${e.message}');

      // Gérer les erreurs spécifiques selon le cours
      switch (e.code) {
        case 'NotAvailable':
          _logger.warning('Biométrie non disponible sur cet appareil');
          break;
        case 'NotEnrolled':
          _logger.warning('Aucune biométrie enregistrée');
          break;
        case 'LockedOut':
          _logger
              .warning('Trop de tentatives - biométrie temporairement bloquée');
          break;
        case 'PermanentlyLockedOut':
          _logger.warning(
              'Biométrie définitivement bloquée - nécessite déverrouillage appareil');
          break;
        case 'UserCanceled':
          _logger.info('Utilisateur a annulé l\'authentification');
          break;
        default:
          _logger.warning(
              'Erreur inconnue lors de l\'authentification biométrique');
      }

      return false;
    } catch (e) {
      _logger.severe('Erreur inattendue lors authentification biométrique', e);
      return false;
    }
  }

  static Future<bool> authenticateForSensitiveAction({
    required String action,
  }) async {
    // Selon le cours : biométrie requise pour actions sensibles
    final availability = await checkAvailability();
    if (availability != BiometricAvailability.available) {
      _logger.warning(
          'Tentative d\'action sensible sans biométrie disponible: $action');
      return false;
    }

    return await authenticate(
      reason: 'Authentification requise pour: $action',
      biometricOnly: true, // Forcer biométrie uniquement
      useErrorDialogs: true,
    );
  }

  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
      _logger.info('Authentification biométrique arrêtée manuellement');
    } catch (e) {
      _logger.warning('Erreur arrêt authentification biométrique', e);
    }
  }

  // Audit des tentatives d'authentification
  static Future<void> auditAuthenticationAttempt({
    required String action,
    required bool success,
    String? errorType,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'action': action,
      'success': success,
      'error_type': errorType,
      'security_event': 'biometric_authentication',
    };

    _logger.info('AUDIT BIOMETRIC: ${logEntry.toString()}');

    // En pratique: envoyer à serveur d'audit sécurisé
  }

  static String getBiometricTypeString(String type) {
    return type; // Déjà converti en chaîne dans getAvailableBiometrics
  }
}

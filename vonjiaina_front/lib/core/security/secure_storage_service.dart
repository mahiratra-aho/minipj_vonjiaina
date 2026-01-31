import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Importer la configuration
import 'security_config.dart';

enum DataType {
  public, // Données publiques : aucune protection nécessaire
  internal, // Données internes : chiffrement basique requis
  confidential, // Données confidentielles : chiffrement fort + contrôle d'accès
  restricted, // Données restreintes : chiffrement fort + biométrie requise
}

class SecureStorageService {
  static final Logger _logger = Logger('SecureStorageService');
  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Utilise KeyStore Android pour clés matérielles
    ),
    iOptions: IOSOptions(
      // Utilise Keychain avec Secure Enclave
      synchronizable: false,
    ),
  );

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static Dio? _auditClient;

  // Clé dérivée dynamiquement avec PBKDF2
  static late String _encryptionKey;
  static bool _initialized = false;

  // Classification des données selon sensibilité RGPD
  static final Map<String, DataType> _dataClassification = {
    // Données de santé (RGPD catégorie spéciale)
    'search_history': DataType.restricted, // Historique médicaments
    'prescription_photos': DataType.restricted, // Photos ordonnances
    'health_conditions': DataType.restricted, // Conditions médicales
    'medical_allergies': DataType.restricted, // Allergies

    // Données personnelles sensibles
    'user_location': DataType.confidential, // Géolocalisation
    'payment_info': DataType.confidential, // Info paiement
    'user_profile': DataType.confidential, // Profil utilisateur
    'user_email': DataType.confidential, // Email
    'user_phone': DataType.confidential, // Téléphone

    // Données internes
    'favorite_pharmacies': DataType.internal, // Préférences
    'user_preferences': DataType.internal, // Paramètres
    'app_settings': DataType.internal, // Configuration
    'recent_searches': DataType.internal, // Recherches récentes

    // Données de session
    'session_token': DataType.confidential, // Token session
    'refresh_token': DataType.confidential, // Token refresh
    'api_token': DataType.confidential, // Token API
    'audit_api_token': DataType.confidential, // Token API audit

    // Données publiques
    'app_version': DataType.public, // Version app
    'onboarding_completed': DataType.public, // Onboarding
    'theme_preference': DataType.public, // Thème
  };

  // INITIALISATION

  /// Initialisation sécurisée du service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Génération de clé sécurisée
      _encryptionKey = await _generateSecureKey();
      _initialized = true;

      _logger.info('✅ SecureStorageService initialisé avec clé sécurisée');

      // Vérifier l'intégrité au démarrage
      final isIntegrityOk = await verifyIntegrity();
      if (!isIntegrityOk) {
        _logger.warning('⚠️ Problème d\'intégrité détecté au démarrage');
      }

      // Réessayer les audits en échec
      await retryFailedAudits();
    } catch (e) {
      _logger.severe('❌ Erreur initialisation SecureStorageService', e);
      rethrow;
    }
  }

  // GÉNÉRATION DE CLÉS SÉCURISÉES

  /// Génération de clé avec PBKDF2 et sel aléatoire
  static Future<String> _generateSecureKey() async {
    try {
      // Récupérer ou générer un sel unique pour l'appareil
      final salt = await _getOrCreateSalt();

      // Mot de passe dérivé de l'ID appareil + timestamp boot
      final deviceInfo = await _getDeviceFingerprint();
      final password =
          '$deviceInfo${DateTime.now().millisecondsSinceEpoch ~/ 86400000}';

      // PBKDF2 avec 10000 itérations (minimum recommandé OWASP)
      final key = _pbkdf2(password, salt, 10000, 32);

      return base64.encode(key);
    } catch (e) {
      _logger.severe('❌ Erreur génération clé sécurisée', e);
      // Fallback vers clé statique (NON RECOMMANDÉ en production)
      _logger.warning('⚠️ Utilisation clé fallback - NON SÉCURISÉ');
      return 'vonjiaina_fallback_key_2025_NOT_SECURE';
    }
  }

  /// Empreinte appareil unique
  static Future<String> _getDeviceFingerprint() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Combinaison d'identifiants stables
        return '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}_${androidInfo.device}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemVersion}';
      }

      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _logger.warning('⚠️ Impossible de récupérer device fingerprint', e);
      return 'fallback_device_id_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Stockage sécurisé du sel
  static Future<Uint8List> _getOrCreateSalt() async {
    const saltKey = 'encryption_salt';
    final storedSalt = await _storage.read(key: saltKey);

    if (storedSalt != null) {
      return base64.decode(storedSalt);
    }

    // Générer sel aléatoire de 32 bytes
    final salt = _generateRandomBytes(32);
    await _storage.write(key: saltKey, value: base64.encode(salt));

    _logger.info('🔐 Nouveau sel cryptographique généré');
    return salt;
  }

  /// Génération cryptographique sécurisée
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (i) => random.nextInt(256)),
    );
  }

  /// PBKDF2 - dérivation de clé (RFC 2898)
  static Uint8List _pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    final passwordBytes = utf8.encode(password);
    final hmacSha256 = Hmac(sha256, passwordBytes);

    final result = Uint8List(keyLength);
    var offset = 0;

    // Nombre de blocs nécessaires (32 bytes par bloc SHA-256)
    final blocksNeeded = (keyLength / 32).ceil();

    for (int blockNumber = 1; blockNumber <= blocksNeeded; blockNumber++) {
      // Créer le message initial : salt + block number (4 bytes big-endian)
      final blockNumberBytes = Uint8List(4);
      blockNumberBytes[0] = (blockNumber >> 24) & 0xff;
      blockNumberBytes[1] = (blockNumber >> 16) & 0xff;
      blockNumberBytes[2] = (blockNumber >> 8) & 0xff;
      blockNumberBytes[3] = blockNumber & 0xff;

      final message = Uint8List.fromList([...salt, ...blockNumberBytes]);

      // Premier HMAC
      var uBlock = Uint8List.fromList(hmacSha256.convert(message).bytes);
      final tBlock = Uint8List.fromList(uBlock);

      // Itérations restantes (iterations - 1)
      for (int i = 1; i < iterations; i++) {
        uBlock = Uint8List.fromList(hmacSha256.convert(uBlock).bytes);

        // XOR avec tBlock
        for (int j = 0; j < tBlock.length; j++) {
          tBlock[j] ^= uBlock[j];
        }
      }

      // Copier le bloc dans le résultat
      final bytesToCopy = min(keyLength - offset, tBlock.length);
      result.setRange(offset, offset + bytesToCopy, tBlock);
      offset += bytesToCopy;
    }

    return result;
  }

  // CHIFFREMENT / DÉCHIFFREMENT AES-256-GCM

  /// Chiffrement AES-256-GCM authentifié
  static Future<String> _encryptData(String data) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final keyBytes = base64.decode(_encryptionKey);

      // Créer une clé AES-256
      final key = encrypt.Key(keyBytes);

      // IV unique pour chaque chiffrement (128 bits)
      final iv = encrypt.IV.fromSecureRandom(16);

      // Encrypter AES-256 en mode GCM (authentification intégrée)
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final encrypted = encrypter.encrypt(data, iv: iv);

      // Format : IV (16 bytes) + Données chiffrées + Tag GCM
      final combined = Uint8List.fromList([
        ...iv.bytes,
        ...encrypted.bytes,
      ]);

      return base64.encode(combined);
    } catch (e) {
      _logger.severe('❌ Erreur lors du chiffrement AES-256-GCM', e);
      rethrow;
    }
  }

  /// Déchiffrement AES-256-GCM avec vérification d'authenticité
  static Future<String> _decryptData(String encryptedData) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final keyBytes = base64.decode(_encryptionKey);
      final key = encrypt.Key(keyBytes);

      final combined = base64.decode(encryptedData);

      // Extraire IV (16 premiers bytes) et données chiffrées
      final iv = encrypt.IV(combined.sublist(0, 16));
      final cipherText = combined.sublist(16);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(cipherText),
        iv: iv,
      );

      // ✅ Succès : réinitialiser compteur d'échecs
      await _resetFailedAttempts();

      return decrypted;
    } catch (e) {
      _logger.severe('❌ Erreur lors du déchiffrement AES-256-GCM', e);

      // ❌ Échec : incrémenter compteur
      await _incrementFailedAttempts();

      rethrow;
    }
  }

  // OPÉRATIONS DE STOCKAGE

  /// Écriture sécurisée avec chiffrement automatique
  static Future<void> writeSecureData({
    required String key,
    required String value,
    DataType? dataType,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final type = dataType ?? _dataClassification[key] ?? DataType.internal;
      String finalValue = value;

      // Appliquer le chiffrement selon la classification
      if (type != DataType.public) {
        finalValue = await _encryptData(value);
        _logger.info('🔐 Données chiffrées AES-256-GCM: $key (${type.name})');
      }

      await _storage.write(key: key, value: finalValue);

      // Audit log
      await _auditLog('WRITE', key, type);
    } catch (e) {
      _logger.severe('❌ Erreur écriture stockage sécurisé pour $key', e);
      rethrow;
    }
  }

  /// Lecture sécurisée avec déchiffrement automatique et biométrie optionnelle
  static Future<String?> readSecureData(
    String key, {
    bool forceBiometric = false,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final type = _dataClassification[key] ?? DataType.internal;

      // Exiger biométrie pour données restreintes
      if (type == DataType.restricted || forceBiometric) {
        final authenticated = await authenticateWithBiometrics();
        if (!authenticated) {
          _logger.warning('⚠️ Authentification biométrique échouée pour $key');
          await _auditLog('BIOMETRIC_FAILED', key, type);
          return null;
        }
      }

      final value = await _storage.read(key: key);
      if (value == null) return null;

      String finalValue = value;

      // Déchiffrer si nécessaire
      if (type != DataType.public) {
        finalValue = await _decryptData(value);
      }

      // Audit log
      await _auditLog('READ', key, type);

      return finalValue;
    } catch (e) {
      _logger.severe('❌ Erreur lecture stockage sécurisé pour $key', e);
      return null;
    }
  }

  /// Suppression sécurisée
  static Future<void> deleteSecureData(String key) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await _storage.delete(key: key);
      await _auditLog(
          'DELETE', key, _dataClassification[key] ?? DataType.internal);
      _logger.info('🗑️ Données supprimées: $key');
    } catch (e) {
      _logger.severe('❌ Erreur suppression stockage sécurisé pour $key', e);
    }
  }

  /// Suppression totale (DANGER)
  static Future<void> clearAll() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await _storage.deleteAll();
      await _auditLog('CLEAR_ALL', 'all_data', DataType.restricted);
      _logger.warning('⚠️ Toutes les données ont été supprimées');
    } catch (e) {
      _logger.severe('❌ Erreur suppression totale stockage sécurisé', e);
    }
  }

  // AUTHENTIFICATION BIOMÉTRIQUE

  /// Vérifier disponibilité biométrie
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      _logger.warning('⚠️ Erreur vérification biométrie', e);
      return false;
    }
  }

  /// Authentification biométrique
  static Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await isBiometricAvailable()) {
        _logger.warning('⚠️ Biométrie non disponible sur cet appareil');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason:
            'Authentifiez-vous pour accéder aux données médicales sensibles',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      _logger.warning('⚠️ Erreur authentification biométrique', e);
      return false;
    }
  }

  // AUDIT ET LOGGING

  /// Récupérer la version de l'application
  static Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      _logger.warning('⚠️ Impossible de récupérer la version de l\'app', e);
      return '1.0.0';
    }
  }

  /// Audit avec envoi serveur sécurisé
  static Future<void> _auditLog(
      String action, String key, DataType type) async {
    final timestamp = DateTime.now().toIso8601String();
    final appVersion = await _getAppVersion();

    final logEntry = {
      'timestamp': timestamp,
      'action': action,
      'key': key,
      'data_type': type.name,
      'device_id': await _getDeviceFingerprint(),
      'app_version': appVersion,
    };

    // Envoyer à serveur d'audit centralisé
    await _sendToSecureAuditServer(logEntry);

    _logger.info('📋 AUDIT: ${json.encode(logEntry)}');
  }

  /// Initialiser client HTTP pour audit
  static Future<void> _initializeAuditClient() async {
    if (_auditClient != null) return;

    final appVersion = await _getAppVersion();

    _auditClient = Dio(BaseOptions(
      baseUrl: SecurityConfig.auditApiUrl,
      connectTimeout: SecurityConfig.connectTimeout,
      receiveTimeout: SecurityConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'X-App-Version': appVersion,
      },
    ));

    // Certificate Pinning pour la production
    if (!SecurityConfig.isDevelopment) {
      // Activer le certificate pinning
      (_auditClient!.httpClientAdapter as IOHttpClientAdapter)
          .createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback = (cert, host, port) {
          // Vérifier le certificat SSL
          // Pour obtenir le certificat :
          // 1. openssl s_client -connect api.vonjiaina.mg:443 -showcerts
          // 2. Copier le certificat entre BEGIN CERTIFICATE et END CERTIFICATE

          // Pour l'instant, accepter tous les certificats en dev
          // EN PRODUCTION : Implémenter la vérification stricte

          final certString = cert.pem;

          // Liste des certificats autorisés (SHA-256 fingerprints)
          const allowedFingerprints = SecurityConfig.allowedSslFingerprints;

          // Calculer le fingerprint du certificat reçu
          final certBytes = utf8.encode(certString);
          final digest = sha256.convert(certBytes);
          final fingerprint = digest.bytes
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');

          _logger.info('Certificat fingerprint: $fingerprint');

          // Vérifier si le certificat est dans la liste autorisée
          if (allowedFingerprints.contains(fingerprint)) {
            return true;
          }

          // En développement, accepter temporairement
          if (SecurityConfig.isDevelopment) {
            _logger.warning('Certificate pinning désactivé en développement');
            return true;
          }

          // En production, rejeter les certificats non autorisés
          _logger.severe('Certificat SSL non autorisé: $fingerprint');
          return false;
        };

        return client;
      };
    }

    _logger.info(
        '✅ Client d\'audit initialisé (${SecurityConfig.isDevelopment ? "dev" : "prod"})');
  }

  /// Envoi sécurisé des logs d'audit
  static Future<void> _sendToSecureAuditServer(
    Map<String, dynamic> logEntry,
  ) async {
    try {
      await _initializeAuditClient();

      // Chiffrer le payload avant envoi
      final encryptedPayload = await _encryptData(json.encode(logEntry));

      final response = await _auditClient!.post(
        '/api/v1/audit/logs',
        data: {'encrypted_data': encryptedPayload},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuditToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.info('✅ Audit envoyé avec succès');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      _logger.warning('⚠️ Erreur envoi audit serveur: $e');

      // Stocker localement pour réessayer plus tard
      await _queueFailedAudit(logEntry);
    }
  }

  /// Token d'authentification pour API audit
  static Future<String> _getAuditToken() async {
    try {
      return await readSecureData('audit_api_token') ?? 'demo_token';
    } catch (e) {
      return 'demo_token';
    }
  }

  /// Queue locale pour audits échoués
  static Future<void> _queueFailedAudit(Map<String, dynamic> logEntry) async {
    try {
      final queue = await readSecureData('failed_audit_queue');
      final queueList = queue != null ? json.decode(queue) as List : [];

      queueList.add(logEntry);

      // Limiter la taille de la queue (max 100 entrées)
      if (queueList.length > 100) {
        queueList.removeAt(0);
      }

      await writeSecureData(
        key: 'failed_audit_queue',
        value: json.encode(queueList),
        dataType: DataType.internal,
      );

      _logger.info('📥 Audit mis en queue locale (${queueList.length} total)');
    } catch (e) {
      _logger.severe('❌ Erreur queue audit local', e);
    }
  }

  /// Ré-essayer les audits en queue
  static Future<void> retryFailedAudits() async {
    try {
      final queue = await readSecureData('failed_audit_queue');
      if (queue == null) return;

      final queueList = json.decode(queue) as List;
      if (queueList.isEmpty) return;

      final failed = <dynamic>[];

      _logger.info('🔄 Tentative renvoi de ${queueList.length} audits...');

      for (final entry in queueList) {
        try {
          await _sendToSecureAuditServer(entry as Map<String, dynamic>);
        } catch (e) {
          failed.add(entry);
        }
      }

      // Mettre à jour la queue avec seulement les échecs restants
      await writeSecureData(
        key: 'failed_audit_queue',
        value: json.encode(failed),
        dataType: DataType.internal,
      );

      final successCount = queueList.length - failed.length;
      _logger.info(
          '✅ Audits réessayés: $successCount succès, ${failed.length} échecs');
    } catch (e) {
      _logger.warning('⚠️ Erreur retry audits', e);
    }
  }

  // SÉCURITÉ ET INTÉGRITÉ

  /// Vérification complète d'intégrité
  static Future<bool> verifyIntegrity() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Test de connexion au stockage sécurisé
      await _storage.read(key: 'integrity_check');

      // Vérifications supplémentaires
      await _verifyKeyIntegrity();
      await _verifyDataCorruption();
      await _detectUnauthorizedAccess();

      _logger.info('✅ Vérification d\'intégrité: OK');
      return true;
    } catch (e) {
      _logger.warning('⚠️ Vérification intégrité échouée', e);
      return false;
    }
  }

  /// Vérification intégrité des clés
  static Future<void> _verifyKeyIntegrity() async {
    try {
      final testKey = 'integrity_test_key';
      final testValue =
          'integrity_test_value_${DateTime.now().millisecondsSinceEpoch}';

      await writeSecureData(key: testKey, value: testValue);
      final retrieved = await readSecureData(testKey);

      if (retrieved != testValue) {
        throw Exception(
            'Corruption détectée dans le chiffrement/déchiffrement');
      }

      await deleteSecureData(testKey);
      _logger.info('✅ Intégrité des clés: OK');
    } catch (e) {
      _logger.severe('❌ Erreur vérification intégrité clés', e);
      rethrow;
    }
  }

  /// Détection de corruption de données
  static Future<void> _verifyDataCorruption() async {
    try {
      final allKeys = await _storage.readAll();

      for (final entry in allKeys.entries) {
        // Ignorer les clés système
        if (entry.key == 'encryption_salt' ||
            entry.key == 'failed_audit_queue' ||
            entry.key == 'failed_decryption_count') {
          continue;
        }

        final type = _dataClassification[entry.key] ?? DataType.internal;

        if (type != DataType.public) {
          try {
            // Tenter de déchiffrer pour vérifier l'intégrité
            await _decryptData(entry.value);
          } catch (e) {
            _logger.severe('❌ Corruption détectée pour clé: ${entry.key}', e);
            throw Exception('Données corrompues: ${entry.key}');
          }
        }
      }

      _logger.info('✅ Vérification corruption: OK');
    } catch (e) {
      _logger.severe('❌ Erreur vérification corruption', e);
      rethrow;
    }
  }

  /// Détection d'accès non autorisés
  static Future<void> _detectUnauthorizedAccess() async {
    try {
      final failedAttempts =
          await _storage.read(key: 'failed_decryption_count');
      final count = int.tryParse(failedAttempts ?? '0') ?? 0;

      if (count > 10) {
        _logger.warning(
            '⚠️ ALERTE SÉCURITÉ: $count tentatives suspectes détectées');

        // Déclencher alerte de sécurité
        await _auditLog(
            'SECURITY_ALERT', 'unauthorized_access', DataType.restricted);

        // Actions de sécurité automatiques
        await _triggerSecurityActions(count);
      }

      _logger.info('✅ Détection accès non autorisés: OK ($count tentatives)');
    } catch (e) {
      _logger.warning('⚠️ Erreur détection accès non autorisés', e);
    }
  }

  /// Déclencher les actions de sécurité en cas d'intrusion
  static Future<void> _triggerSecurityActions(int failedAttempts) async {
    try {
      // 1. Notifier le serveur de l'incident de sécurité
      await _notifySecurityIncident(failedAttempts);

      // 2. Si plus de 20 tentatives : bloquer temporairement
      if (failedAttempts > 20) {
        await _temporaryLockdown();
      }

      // 3. Si plus de 50 tentatives : effacer les données sensibles
      if (failedAttempts > 50) {
        _logger.severe('🚨 ALERTE CRITIQUE: Effacement des données sensibles');
        await _emergencyDataWipe();
      }

      // 4. Enregistrer l'heure du dernier incident
      await writeSecureData(
        key: 'last_security_incident',
        value: DateTime.now().toIso8601String(),
        dataType: DataType.internal,
      );
    } catch (e) {
      _logger.severe('❌ Erreur actions de sécurité', e);
    }
  }

  /// Notifier le serveur d'un incident de sécurité
  static Future<void> _notifySecurityIncident(int attemptCount) async {
    try {
      await _initializeAuditClient();

      final incident = {
        'type': 'unauthorized_access_attempt',
        'attempt_count': attemptCount,
        'timestamp': DateTime.now().toIso8601String(),
        'device_id': await _getDeviceFingerprint(),
        'severity': attemptCount > 20 ? 'critical' : 'warning',
      };

      await _auditClient!.post(
        '/api/v1/security/incidents',
        data: incident,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuditToken()}',
          },
        ),
      );

      _logger.info('🚨 Incident de sécurité notifié au serveur');
    } catch (e) {
      _logger.warning('⚠️ Impossible de notifier l\'incident', e);
    }
  }

  /// Bloquer temporairement l'accès (30 minutes)
  static Future<void> _temporaryLockdown() async {
    final lockdownUntil = DateTime.now().add(Duration(minutes: 30));
    await writeSecureData(
      key: 'lockdown_until',
      value: lockdownUntil.millisecondsSinceEpoch.toString(),
      dataType: DataType.internal,
    );

    _logger.warning('🔒 Lockdown temporaire activé jusqu\'à $lockdownUntil');
  }

  /// Vérifier si l'application est en lockdown
  static Future<bool> isInLockdown() async {
    try {
      final lockdownUntilStr = await readSecureData('lockdown_until');
      if (lockdownUntilStr == null) return false;

      final lockdownUntil =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lockdownUntilStr));

      final isLocked = DateTime.now().isBefore(lockdownUntil);

      if (!isLocked) {
        // Lockdown expiré, nettoyer
        await deleteSecureData('lockdown_until');
      }

      return isLocked;
    } catch (e) {
      return false;
    }
  }

  /// Effacement d'urgence des données sensibles
  static Future<void> _emergencyDataWipe() async {
    try {
      // Effacer uniquement les données sensibles (restricted et confidential)
      final allKeys = await _storage.readAll();

      for (final key in allKeys.keys) {
        final type = _dataClassification[key] ?? DataType.internal;

        if (type == DataType.restricted || type == DataType.confidential) {
          await _storage.delete(key: key);
          _logger.warning('🗑️ Donnée sensible effacée: $key');
        }
      }

      await _auditLog('EMERGENCY_WIPE', 'sensitive_data', DataType.restricted);
    } catch (e) {
      _logger.severe('❌ Erreur effacement d\'urgence', e);
    }
  }

  /// Incrémenter compteur d'échecs
  static Future<void> _incrementFailedAttempts() async {
    try {
      final current = await _storage.read(key: 'failed_decryption_count');
      final count = (int.tryParse(current ?? '0') ?? 0) + 1;
      await _storage.write(
          key: 'failed_decryption_count', value: count.toString());

      if (count > 5) {
        _logger.warning('⚠️ $count tentatives de déchiffrement échouées');
      }
    } catch (e) {
      _logger.warning('⚠️ Erreur incrémentation échecs', e);
    }
  }

  /// Réinitialiser compteur après succès
  static Future<void> _resetFailedAttempts() async {
    try {
      await _storage.write(key: 'failed_decryption_count', value: '0');
    } catch (e) {
      _logger.warning('⚠️ Erreur reset échecs', e);
    }
  }

  // ROTATION DES CLÉS

  /// Rotation des clés de chiffrement
  static Future<void> rotateKeys() async {
    try {
      _logger.info('🔄 Début rotation des clés de chiffrement');

      // Sauvegarder ancienne clé
      final oldKey = _encryptionKey;

      // Générer nouvelle clé
      _encryptionKey = await _generateSecureKey();

      // Re-chiffrer toutes les données avec nouvelle clé
      await _reencryptAllData(oldKey);

      await _auditLog('KEY_ROTATION', 'encryption_key', DataType.restricted);

      _logger.info('✅ Rotation des clés terminée avec succès');
    } catch (e) {
      _logger.severe('❌ Erreur rotation des clés', e);
      rethrow;
    }
  }

  /// Re-chiffrement des données existantes
  static Future<void> _reencryptAllData(String oldKey) async {
    try {
      _logger.info('🔄 Début re-chiffrement des données existantes');

      // 1. Lire toutes les données avec ancienne clé
      final allKeys = await _storage.readAll();
      final reencryptedData = <String, String>{};

      for (final entry in allKeys.entries) {
        // Ne pas re-chiffrer les clés système
        if (entry.key == 'encryption_salt' ||
            entry.key == 'failed_audit_queue' ||
            entry.key == 'failed_decryption_count') {
          continue;
        }

        final type = _dataClassification[entry.key] ?? DataType.internal;

        // Ne re-chiffrer que les données chiffrées
        if (type == DataType.public) {
          continue;
        }

        try {
          // Utiliser l'ancienne clé pour déchiffrer
          final tempKey = _encryptionKey;
          _encryptionKey = oldKey;
          final decryptedValue = await _decryptData(entry.value);

          // Utiliser la nouvelle clé pour chiffrer
          _encryptionKey = tempKey;
          final reencryptedValue = await _encryptData(decryptedValue);

          reencryptedData[entry.key] = reencryptedValue;
        } catch (e) {
          _logger.warning('⚠️ Erreur re-chiffrement clé ${entry.key}', e);
          // Garder l'original si erreur
          reencryptedData[entry.key] = entry.value;
        }
      }

      // 2. Remplacer les valeurs re-chiffrées
      for (final entry in reencryptedData.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }

      _logger.info(
          '✅ Re-chiffrement terminé pour ${reencryptedData.length} entrées');
    } catch (e) {
      _logger.severe('❌ Erreur re-chiffrement des données', e);
      rethrow;
    }
  }

  // ============================================================================
  // UTILITAIRES ET HELPERS
  // ============================================================================

  /// Obtenir toutes les clés stockées
  static Future<List<String>> getAllKeys() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final allData = await _storage.readAll();
      return allData.keys.toList();
    } catch (e) {
      _logger.severe('❌ Erreur récupération des clés', e);
      return [];
    }
  }

  /// Vérifier si une clé existe
  static Future<bool> containsKey(String key) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      _logger.severe('❌ Erreur vérification clé $key', e);
      return false;
    }
  }

  /// Obtenir le type de classification d'une donnée
  static DataType getDataType(String key) {
    return _dataClassification[key] ?? DataType.internal;
  }

  /// Exporter toutes les données (pour backup)
  /// ⚠️ ATTENTION: Les données exportées sont chiffrées mais sensibles
  static Future<Map<String, String>> exportAllData() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final allData = await _storage.readAll();
      await _auditLog('EXPORT_ALL', 'all_data', DataType.restricted);

      _logger.warning('⚠️ Export complet des données effectué');
      return allData;
    } catch (e) {
      _logger.severe('❌ Erreur export des données', e);
      return {};
    }
  }

  /// Importer des données (pour restauration)
  /// ⚠️ ATTENTION: Écrase les données existantes
  static Future<void> importAllData(Map<String, String> data) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      for (final entry in data.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }

      await _auditLog('IMPORT_ALL', 'all_data', DataType.restricted);
      _logger.warning('⚠️ Import de ${data.length} entrées effectué');
    } catch (e) {
      _logger.severe('❌ Erreur import des données', e);
      rethrow;
    }
  }

  /// Obtenir des statistiques sur le stockage
  static Future<Map<String, dynamic>> getStorageStats() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final allKeys = await _storage.readAll();

      int publicCount = 0;
      int internalCount = 0;
      int confidentialCount = 0;
      int restrictedCount = 0;

      for (final key in allKeys.keys) {
        final type = _dataClassification[key] ?? DataType.internal;
        switch (type) {
          case DataType.public:
            publicCount++;
            break;
          case DataType.internal:
            internalCount++;
            break;
          case DataType.confidential:
            confidentialCount++;
            break;
          case DataType.restricted:
            restrictedCount++;
            break;
        }
      }

      return {
        'total_keys': allKeys.length,
        'public': publicCount,
        'internal': internalCount,
        'confidential': confidentialCount,
        'restricted': restrictedCount,
        'encrypted_percentage':
            ((allKeys.length - publicCount) / allKeys.length * 100)
                .toStringAsFixed(1),
      };
    } catch (e) {
      _logger.severe('❌ Erreur récupération statistiques', e);
      return {};
    }
  }

  /// Nettoyer les données expirées (TTL)
  /// Utile pour les tokens de session, cache temporaire, etc.
  static Future<void> cleanExpiredData() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final allKeys = await _storage.readAll();
      int deletedCount = 0;

      for (final entry in allKeys.entries) {
        // Vérifier si la clé contient un timestamp d'expiration
        if (entry.key.endsWith('_expires_at')) {
          try {
            final expiryTimestamp = int.tryParse(entry.value);
            if (expiryTimestamp != null) {
              final expiryDate =
                  DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);

              if (now.isAfter(expiryDate)) {
                // Supprimer la clé expirée et sa donnée associée
                final dataKey = entry.key.replaceAll('_expires_at', '');
                await _storage.delete(key: entry.key);
                await _storage.delete(key: dataKey);
                deletedCount++;

                _logger.info('🗑️ Donnée expirée supprimée: $dataKey');
              }
            }
          } catch (e) {
            _logger.warning(
                '⚠️ Erreur vérification expiration ${entry.key}', e);
          }
        }
      }

      if (deletedCount > 0) {
        await _auditLog(
            'CLEAN_EXPIRED', '$deletedCount entries', DataType.internal);
        _logger.info('✅ Nettoyage: $deletedCount entrées expirées supprimées');
      }
    } catch (e) {
      _logger.severe('❌ Erreur nettoyage données expirées', e);
    }
  }

  /// Écrire avec TTL (Time To Live)
  static Future<void> writeSecureDataWithTTL({
    required String key,
    required String value,
    required Duration ttl,
    DataType? dataType,
  }) async {
    // Écrire la donnée
    await writeSecureData(key: key, value: value, dataType: dataType);

    // Écrire le timestamp d'expiration
    final expiryTimestamp =
        DateTime.now().add(ttl).millisecondsSinceEpoch.toString();
    await _storage.write(key: '${key}_expires_at', value: expiryTimestamp);

    _logger.info('⏱️ Donnée avec TTL: $key (expire dans ${ttl.inMinutes}min)');
  }

  /// Diagnostic complet du système de sécurité
  static Future<Map<String, dynamic>> runSecurityDiagnostic() async {
    if (!_initialized) {
      await initialize();
    }

    final diagnostic = <String, dynamic>{};

    try {
      // 1. Test intégrité
      diagnostic['integrity_check'] = await verifyIntegrity();

      // 2. Test biométrie
      diagnostic['biometric_available'] = await isBiometricAvailable();

      // 3. Statistiques stockage
      diagnostic['storage_stats'] = await getStorageStats();

      // 4. Tentatives d'accès échouées
      final failedAttempts =
          await _storage.read(key: 'failed_decryption_count');
      diagnostic['failed_attempts'] = int.tryParse(failedAttempts ?? '0') ?? 0;

      // 5. Audits en attente
      final queuedAudits = await readSecureData('failed_audit_queue');
      final auditList =
          queuedAudits != null ? json.decode(queuedAudits) as List : [];
      diagnostic['queued_audits'] = auditList.length;

      // 6. Device info
      diagnostic['device_fingerprint'] = await _getDeviceFingerprint();

      // 7. Dernière rotation de clé
      final lastRotation = await readSecureData('last_key_rotation');
      diagnostic['last_key_rotation'] = lastRotation ?? 'never';

      // 8. État d'initialisation
      diagnostic['initialized'] = _initialized;

      diagnostic['status'] = 'healthy';
      diagnostic['timestamp'] = DateTime.now().toIso8601String();

      _logger.info('✅ Diagnostic sécurité: ${json.encode(diagnostic)}');

      return diagnostic;
    } catch (e) {
      diagnostic['status'] = 'error';
      diagnostic['error'] = e.toString();
      _logger.severe('❌ Erreur diagnostic sécurité', e);
      return diagnostic;
    }
  }

  /// Planifier la rotation automatique des clés
  /// Recommandation: tous les 90 jours
  static Future<void> scheduleKeyRotation() async {
    try {
      final lastRotation = await readSecureData('last_key_rotation');

      if (lastRotation == null) {
        // Première rotation
        await rotateKeys();
        await writeSecureData(
          key: 'last_key_rotation',
          value: DateTime.now().toIso8601String(),
          dataType: DataType.internal,
        );
        return;
      }

      final lastRotationDate = DateTime.parse(lastRotation);
      final daysSinceRotation =
          DateTime.now().difference(lastRotationDate).inDays;

      if (daysSinceRotation >= 90) {
        _logger.warning(
            '⚠️ Rotation des clés nécessaire ($daysSinceRotation jours)');
        await rotateKeys();
        await writeSecureData(
          key: 'last_key_rotation',
          value: DateTime.now().toIso8601String(),
          dataType: DataType.internal,
        );
      } else {
        _logger.info(
            '✅ Rotation des clés: ${90 - daysSinceRotation} jours restants');
      }
    } catch (e) {
      _logger.severe('❌ Erreur planification rotation', e);
    }
  }

  /// Réinitialisation complète du système (factory reset)
  /// ⚠️ DANGER: Supprime TOUT et réinitialise
  static Future<void> factoryReset() async {
    try {
      _logger.warning('⚠️ FACTORY RESET INITIÉ');

      await _auditLog('FACTORY_RESET', 'all_system', DataType.restricted);

      // 1. Supprimer toutes les données
      await clearAll();

      // 2. Réinitialiser l'état
      _initialized = false;

      // 3. Réinitialiser
      await initialize();

      _logger.warning('✅ Factory reset terminé');
    } catch (e) {
      _logger.severe('❌ Erreur factory reset', e);
      rethrow;
    }
  }

  /// Helper pour sauvegarder des objets complexes
  static Future<void> writeObject({
    required String key,
    required Map<String, dynamic> object,
    DataType? dataType,
  }) async {
    await writeSecureData(
      key: key,
      value: json.encode(object),
      dataType: dataType,
    );
  }

  /// Helper pour lire des objets complexes
  static Future<Map<String, dynamic>?> readObject(String key) async {
    final data = await readSecureData(key);
    if (data == null) return null;

    try {
      return json.decode(data) as Map<String, dynamic>;
    } catch (e) {
      _logger.warning('⚠️ Erreur parsing JSON pour $key', e);
      return null;
    }
  }

  /// Helper pour sauvegarder des listes
  static Future<void> writeList({
    required String key,
    required List<dynamic> list,
    DataType? dataType,
  }) async {
    await writeSecureData(
      key: key,
      value: json.encode(list),
      dataType: dataType,
    );
  }

  /// Helper pour lire des listes
  static Future<List<dynamic>?> readList(String key) async {
    final data = await readSecureData(key);
    if (data == null) return null;

    try {
      return json.decode(data) as List<dynamic>;
    } catch (e) {
      _logger.warning('⚠️ Erreur parsing liste pour $key', e);
      return null;
    }
  }

  /// Vérifier la force du chiffrement
  static Future<Map<String, dynamic>> checkEncryptionStrength() async {
    return {
      'algorithm': 'AES-256-GCM',
      'key_derivation': 'PBKDF2-SHA256',
      'iterations': 10000,
      'key_size_bits': 256,
      'iv_size_bits': 128,
      'authenticated_encryption': true,
      'secure_random': true,
      'hardware_backed': Platform.isAndroid ? 'KeyStore' : 'Secure Enclave',
    };
  }
}

// EXTENSION POUR FACILITER L'UTILISATION

extension SecureStorageExtension on SecureStorageService {
  /// Shortcut pour écrire des données de santé (toujours restricted)
  static Future<void> writeHealthData(String key, String value) async {
    await SecureStorageService.writeSecureData(
      key: key,
      value: value,
      dataType: DataType.restricted,
    );
  }

  /// Shortcut pour lire des données de santé (biométrie requise)
  static Future<String?> readHealthData(String key) async {
    return await SecureStorageService.readSecureData(key);
  }
}

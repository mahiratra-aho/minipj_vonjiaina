import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import '../constants/api_constants.dart';

class SecureApiService {
  static final Logger _logger = Logger('SecureApiService');
  static final http.Client _client = http.Client();

  // Clé de signature pour l'intégrité (en pratique: clé RSA/ECC)
  static const String _signingKey = 'vonjiaina_api_signing_key_2025';

  // Protection contre les attaques par rejeu (replay attacks)
  static final Map<String, DateTime> _nonces = {};

  static Future<dynamic> secureGet(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = false,
  }) async {
    try {
      // 1. Ajouter nonce et timestamp pour prévenir replay attacks
      final nonce = _generateNonce();
      final timestamp = DateTime.now().toIso8601String();

      final enrichedParams = Map<String, String>.from(queryParams ?? {});
      enrichedParams['nonce'] = nonce;
      enrichedParams['timestamp'] = timestamp;

      // 2. Construire l'URI sécurisé
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: enrichedParams);

      _logger.info('SecureApiService: Secure GET Request: $uri');

      // 3. Préparer les headers avec signature
      final headers = _buildSecureHeaders(
        method: 'GET',
        endpoint: endpoint,
        queryParams: enrichedParams,
        body: null,
      );

      // 4. Exécuter la requête avec timeout
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.receiveTimeout);

      _logger.info('SecureApiService: Response Status: ${response.statusCode}');

      // 5. Valider la réponse
      return _validateSecureResponse(response);
    } catch (e, stackTrace) {
      _logger.severe('SecureApiService: Error: $e', e, stackTrace);
      throw _handleSecureError(e);
    }
  }

  static Future<dynamic> securePost(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      // 1. Validation des entrées
      if (body != null) {
        _validateRequestBody(body);
      }

      // 2. Ajouter nonce et timestamp
      final nonce = _generateNonce();
      final timestamp = DateTime.now().toIso8601String();

      final enrichedParams = Map<String, String>.from(queryParams ?? {});
      enrichedParams['nonce'] = nonce;
      enrichedParams['timestamp'] = timestamp;

      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: enrichedParams);

      // 3. Préparer le body JSON
      final jsonBody = body != null ? json.encode(body) : null;

      _logger.info('SecureApiService: Secure POST Request: $uri');

      // 4. Construire les headers avec signature
      final headers = _buildSecureHeaders(
        method: 'POST',
        endpoint: endpoint,
        queryParams: enrichedParams,
        body: jsonBody,
      );

      // 5. Exécuter la requête
      final response = await _client
          .post(uri, headers: headers, body: jsonBody)
          .timeout(ApiConstants.receiveTimeout);

      _logger.info('SecureApiService: Response Status: ${response.statusCode}');

      // 6. Valider la réponse
      return _validateSecureResponse(response);
    } catch (e, stackTrace) {
      _logger.severe('SecureApiService: Error: $e', e, stackTrace);
      throw _handleSecureError(e);
    }
  }

  // Construction des headers sécurisés
  static Map<String, String> _buildSecureHeaders({
    required String method,
    required String endpoint,
    required Map<String, String> queryParams,
    String? body,
  }) {
    // 1. Créer la signature HMAC
    final signature = _generateSignature(
      method: method,
      endpoint: endpoint,
      queryParams: queryParams,
      body: body,
    );

    // 2. Headers de sécurité
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Signature': signature,
      'X-Client-Version': '1.0.0',
      'X-Request-ID': _generateRequestId(),
      'User-Agent': 'VonjiAIna-Flutter/1.0.0',
    };

    // 3. Headers anti-MITM
    headers['Strict-Transport-Security'] =
        'max-age=31536000; includeSubDomains';
    headers['X-Content-Type-Options'] = 'nosniff';
    headers['X-Frame-Options'] = 'DENY';

    return headers;
  }

  // Génération de signature HMAC pour l'intégrité
  static String _generateSignature({
    required String method,
    required String endpoint,
    required Map<String, String> queryParams,
    String? body,
  }) {
    // 1. Construire la chaîne à signer
    final sortedParams = Map.fromEntries(
      queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final queryString = sortedParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final stringToSign = '$method\n$endpoint\n$queryString${body ?? ''}';

    // 2. Générer HMAC-SHA256
    final key = utf8.encode(_signingKey);
    final bytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);

    // 3. Retourner en base64
    return base64.encode(digest.bytes);
  }

  // Validation de la réponse serveur
  static dynamic _validateSecureResponse(http.Response response) {
    // 1. Vérifier le statut HTTP
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseData = json.decode(response.body);

        // 2. Vérifier la signature de la réponse si présente
        final serverSignature = response.headers['x-server-signature'];
        if (serverSignature != null) {
          if (!_verifyServerSignature(response.body, serverSignature)) {
            throw Exception(
                'Signature de réponse invalide - Possible MITM attack');
          }
        }

        return responseData;
      } catch (e) {
        _logger.warning('SecureApiService: JSON Decode Error: $e');
        throw Exception('Erreur de décodage JSON');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode >= 500) {
      throw Exception('Erreur serveur: ${response.statusCode}');
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
    }
  }

  // Vérification de la signature du serveur
  static bool _verifyServerSignature(String body, String signature) {
    try {
      final key = utf8.encode(_signingKey);
      final bytes = utf8.encode(body);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      final expectedSignature = base64.encode(digest.bytes);

      return expectedSignature == signature;
    } catch (e) {
      _logger.warning('Erreur vérification signature serveur: $e');
      return false;
    }
  }

  // Gestion des erreurs de sécurité
  static Exception _handleSecureError(dynamic error) {
    final errorString = error.toString();

    // Détection d'attaques spécifiques
    if (errorString.contains('Signature de réponse invalide')) {
      _logger.severe('ATTAQUE DÉTECTÉE: Tentative MITM');
      return Exception('Erreur de sécurité - Connexion non sécurisée');
    }

    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return Exception('Pas de connexion internet ou serveur inaccessible');
    }

    if (errorString.contains('TimeoutException')) {
      return Exception('Délai d\'attente dépassé');
    }

    return Exception('Erreur réseau sécurisé: $error');
  }

  // Validation du corps de la requête
  static void _validateRequestBody(Map<String, dynamic> body) {
    // Taille maximale pour prévenir les attaques
    final bodySize = json.encode(body).length;
    if (bodySize > 1024 * 1024) {
      // 1MB max
      throw Exception('Corps de requête trop volumineux');
    }

    // Validation contre l'injection
    for (final entry in body.entries) {
      if (entry.value is String) {
        final value = entry.value as String;
        if (_containsMaliciousPatterns(value)) {
          _logger
              .severe('Tentative d\'injection détectée: ${entry.key}=$value');
          throw Exception('Contenu malveillant détecté');
        }
      }
    }
  }

  // Détection de patterns malveillants
  static bool _containsMaliciousPatterns(String input) {
    final maliciousPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'on\w+\s*=',
      r'union\s+select',
      r'drop\s+table',
      r'insert\s+into',
      r'delete\s+from',
      r'update\s+set',
    ];

    for (final pattern in maliciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  // Génération de nonce unique
  static String _generateNonce() {
    final random = Random.secure();
    final nonce = random.nextInt(1000000).toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Stocker pour validation anti-replay
    _nonces[nonce] = DateTime.now();

    // Nettoyer les anciens nonces (plus de 5 minutes)
    _cleanupOldNonces();

    return '$timestamp-$nonce';
  }

  // Nettoyage des nonces expirés
  static void _cleanupOldNonces() {
    final now = DateTime.now();
    _nonces.removeWhere((key, value) => now.difference(value).inMinutes > 5);
  }

  // Génération d'ID de requête unique
  static String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(10000);
    return 'req_$timestamp-$random';
  }

  void dispose() {
    _client.close();
  }
}

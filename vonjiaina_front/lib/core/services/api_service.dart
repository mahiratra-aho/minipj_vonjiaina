import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:logging/logging.dart';

class ApiService {
  final http.Client _client;
  static final Logger _logger = Logger('ApiService');

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);

      _logger.warning('ApiService: GET Request: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.receiveTimeout);

      _logger.warning('ApiService: Response Status: ${response.statusCode}');
      _logger.warning('ApiService: Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _logger.warning('ApiService: Error: $e');
      _logger.warning('ApiService: StackTrace: $stackTrace');
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        _logger.warning('ApiService: JSON Decode Error: $e');
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

  Exception _handleError(dynamic error) {
    final errorString = error.toString();

    _logger.warning('ApiService: Analyzing error: $errorString');

    if (errorString.contains('XMLHttpRequest')) {
      return Exception(
          'Erreur CORS: Vérifiez la configuration CORS du serveur');
    }
    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return Exception('Pas de connexion internet ou serveur inaccessible');
    }
    if (errorString.contains('TimeoutException')) {
      return Exception('Délai d\'attente dépassé');
    }
    if (errorString.contains('Connection refused')) {
      return Exception('Connexion refusée: Le serveur est-il démarré ?');
    }

    return Exception('Erreur réseau: $error');
  }

  void dispose() {
    _client.close();
  }
}

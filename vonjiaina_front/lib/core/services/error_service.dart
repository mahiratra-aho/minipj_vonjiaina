import 'package:logging/logging.dart';

enum ErrorType {
  network,
  location,
  api,
  validation,
  unknown,
}

class AppError {
  final String userMessage;
  final String technicalMessage;
  final ErrorType type;

  AppError({
    required this.userMessage,
    required this.technicalMessage,
    required this.type,
  });
}

class ErrorService {
  static final Logger _logger = Logger('ErrorService');

  static AppError handleError(dynamic error) {
    final errorString = error.toString();

    _logger.warning('ErrorService: Analyzing error: $errorString');

    // Erreurs réseau
    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Network is unreachable')) {
      return AppError(
        userMessage:
            'Problème de connexion\nVérifiez votre internet et réessayez',
        technicalMessage: errorString,
        type: ErrorType.network,
      );
    }

    // Erreurs de timeout
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return AppError(
        userMessage:
            'Connexion trop lente\nVérifiez votre connexion ou réessayez plus tard',
        technicalMessage: errorString,
        type: ErrorType.network,
      );
    }

    // Erreurs de localisation
    if (errorString.contains('Permission') ||
        errorString.contains('Location') ||
        errorString.contains('GPS') ||
        errorString.contains('localisation')) {
      return AppError(
        userMessage:
            'Problème de localisation\nActivez votre GPS et autorisez l\'accès',
        technicalMessage: errorString,
        type: ErrorType.location,
      );
    }

    // Erreurs HTTP spécifiques
    if (errorString.contains('404')) {
      return AppError(
        userMessage: 'Service indisponible\nRéessayez dans quelques instants',
        technicalMessage: errorString,
        type: ErrorType.api,
      );
    }

    if (errorString.contains('500') || errorString.contains('Erreur serveur')) {
      return AppError(
        userMessage:
            'Serveur momentanément indisponible\nNous réparons le problème',
        technicalMessage: errorString,
        type: ErrorType.api,
      );
    }

    // Erreurs de validation
    if (errorString.contains('Veuillez entrer') ||
        errorString.contains('champ') ||
        errorString.contains('requis')) {
      return AppError(
        userMessage: errorString,
        technicalMessage: errorString,
        type: ErrorType.validation,
      );
    }

    // Erreur par défaut
    return AppError(
      userMessage: 'Une erreur est survenue\nRéessayez ou contactez le support',
      technicalMessage: errorString,
      type: ErrorType.unknown,
    );
  }

  static void logError(AppError error, {String? context}) {
    final contextInfo = context != null ? '[$context] ' : '';
    _logger.severe('${contextInfo}User: ${error.userMessage}');
    _logger.severe('${contextInfo}Technical: ${error.technicalMessage}');
    _logger.severe('${contextInfo}Type: ${error.type.name}');
  }
}

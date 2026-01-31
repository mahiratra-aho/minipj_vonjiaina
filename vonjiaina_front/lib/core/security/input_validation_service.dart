import 'package:logging/logging.dart';

class InputValidationService {
  static final Logger _logger = Logger('InputValidationService');

  // Validation des entrées utilisateur selon le cours
  static ValidationResult validateMedicamentName(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom du médicament est requis',
        errorCode: 'EMPTY_INPUT',
      );
    }

    if (input.length < 2) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom du médicament doit contenir au moins 2 caractères',
        errorCode: 'INPUT_TOO_SHORT',
      );
    }

    if (input.length > 100) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom du médicament est trop long (max 100 caractères)',
        errorCode: 'INPUT_TOO_LONG',
      );
    }

    // Protection contre l'injection SQL et XSS
    if (_containsSqlInjection(input)) {
      _logger.warning('Tentative d\'injection SQL détectée: $input');
      return ValidationResult(
        isValid: false,
        error: 'Caractères non autorisés détectés',
        errorCode: 'SQL_INJECTION_ATTEMPT',
      );
    }

    if (_containsXssPatterns(input)) {
      _logger.warning('Tentative XSS détectée: $input');
      return ValidationResult(
        isValid: false,
        error: 'Caractères non autorisés détectés',
        errorCode: 'XSS_ATTEMPT',
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateSearchQuery(String query) {
    final basicValidation = validateMedicamentName(query);
    if (!basicValidation.isValid) {
      return basicValidation;
    }

    // Validation spécifique pour les requêtes de recherche
    if (_containsControlCharacters(query)) {
      return ValidationResult(
        isValid: false,
        error: 'Caractères de contrôle non autorisés',
        errorCode: 'CONTROL_CHARACTERS',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Protection contre les attaques par chaîne de format dans les logs
  static String sanitizeForLogging(String input) {
    // Supprimer les caractères de formatage qui pourraient corrompre les logs
    return input
        .replaceAll('%', '%%')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  // Nettoyage des entrées pour éviter les injections
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Protection XSS basique
        .replaceAll(RegExp(r'["\\]'), '') // Protection SQL basique
        .replaceAll(RegExp(r'--'), '') // Commentaires SQL
        .replaceAll(RegExp(r';'), ''); // Terminaisons SQL
  }

  // Détection d'injection SQL
  static bool _containsSqlInjection(String input) {
    final sqlPatterns = [
      r'(?i)\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b',
      r'(?i)\b(or|and)\s+\d+\s*=\s*\d+',
      r"(?i)\'\s*or\s*\'",
      r'(?i)\*\|',
      r'(?i)--',
      r'(?i);',
      r'(?i)\/\*',
      r'(?i)\*\/',
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  // Détection de patterns XSS
  static bool _containsXssPatterns(String input) {
    final xssPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'on\w+\s*=', // onclick, onload, etc.
      r'<iframe[^>]*>',
      r'<object[^>]*>',
      r'<embed[^>]*>',
      r'eval\s*\(',
      r'expression\s*\(',
    ];

    for (final pattern in xssPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  // Détection de caractères de contrôle
  static bool _containsControlCharacters(String input) {
    return RegExp(r'[\x00-\x1F\x7F]').hasMatch(input);
  }

  // Validation des adresses (pour futures fonctionnalités)
  static ValidationResult validateAddress(String address) {
    if (address.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'L\'adresse est requise',
        errorCode: 'EMPTY_ADDRESS',
      );
    }

    if (address.length > 200) {
      return ValidationResult(
        isValid: false,
        error: 'L\'adresse est trop longue (max 200 caractères)',
        errorCode: 'ADDRESS_TOO_LONG',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Audit des validations
  static void logValidationAttempt({
    required String inputType,
    required String input,
    required bool isValid,
    String? errorCode,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'input_type': inputType,
      'input_length': input.length,
      'is_valid': isValid,
      'error_code': errorCode,
      'security_event': 'input_validation',
    };

    _logger.info('AUDIT VALIDATION: ${logEntry.toString()}');
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;
  final String? errorCode;

  ValidationResult({
    required this.isValid,
    this.error,
    this.errorCode,
  });
}

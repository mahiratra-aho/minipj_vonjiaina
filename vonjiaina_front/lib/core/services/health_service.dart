import 'package:logging/logging.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import '../../data/models/health_models.dart';

class HealthService {
  final ApiService _api = ApiService();
  static final Logger _logger = Logger('HealthService');

  Future<List<MedicamentRappel>> getRappels() async {
    try {
      final response = await _api.get('${ApiConstants.apiVersion}/rappels');
      
      if (response is List) {
        return response.map<MedicamentRappel>((json) => MedicamentRappel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.warning('Error getting rappels: $e');
      return [];
    }
  }

  Future<bool> addRappel(MedicamentRappel rappel) async {
    try {
      final response = await _api.post('${ApiConstants.apiVersion}/rappels', data: rappel.toJson());
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error adding rappel: $e');
      return false;
    }
  }

  Future<bool> updateRappel(MedicamentRappel rappel) async {
    try {
      _logger.warning('Updating rappel: ${rappel.id}');
      _logger.warning('Rappel data: ${rappel.toJson()}');
      
      final response = await _api.put('${ApiConstants.apiVersion}/rappels/${rappel.id}', data: rappel.toJson());
      
      _logger.warning('Update response: $response');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error updating rappel: $e');
      return false;
    }
  }

  Future<bool> deleteRappel(String rappelId) async {
    try {
      final response = await _api.delete('${ApiConstants.apiVersion}/rappels/$rappelId');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error deleting rappel: $e');
      return false;
    }
  }

  Future<bool> toggleRappel(String rappelId) async {
    try {
      final response = await _api.put('${ApiConstants.apiVersion}/rappels/$rappelId/toggle');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error toggling rappel: $e');
      return false;
    }
  }

  Future<List<EtatSante>> getEtatsSante() async {
    try {
      final response = await _api.get('${ApiConstants.apiVersion}/etats-sante');
      
      if (response is List) {
        return response.map<EtatSante>((json) => EtatSante.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.warning('Error getting etats sante: $e');
      return [];
    }
  }

  Future<bool> addEtatSante(EtatSante etat) async {
    try {
      final response = await _api.post('${ApiConstants.apiVersion}/etats-sante', data: etat.toJson());
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error adding etat sante: $e');
      return false;
    }
  }

  Future<bool> updateEtatSante(EtatSante etat) async {
    try {
      final response = await _api.put('${ApiConstants.apiVersion}/etats-sante/${etat.id}', data: etat.toJson());
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error updating etat sante: $e');
      return false;
    }
  }

  Future<bool> deleteEtatSante(String etatId) async {
    try {
      final response = await _api.delete('${ApiConstants.apiVersion}/etats-sante/$etatId');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Error deleting etat sante: $e');
      return false;
    }
  }
}

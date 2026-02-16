import 'package:flutter/foundation.dart';
import '../../core/services/database_service.dart';
import '../../data/models/health_models.dart';

class HealthViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<MedicamentRappel> _rappels = [];
  List<EtatSante> _etatsSante = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MedicamentRappel> get rappels => _rappels;
  List<EtatSante> get etatsSante => _etatsSante;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== RAPPELS ====================

  Future<void> loadRappels() async {
    _setLoading(true);
    _clearError();
    
    try {
      _rappels = await _databaseService.getRappels();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des rappels: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addRappel(MedicamentRappel rappel) async {
    _clearError();
    
    try {
      final success = await _databaseService.addRappel(rappel);
      if (success) {
        await loadRappels(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de l\'ajout du rappel: $e');
      return false;
    }
  }

  Future<bool> updateRappel(MedicamentRappel rappel) async {
    _clearError();
    
    try {
      final success = await _databaseService.updateRappel(rappel);
      if (success) {
        await loadRappels(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du rappel: $e');
      return false;
    }
  }

  Future<bool> deleteRappel(String id) async {
    _clearError();
    
    try {
      final success = await _databaseService.deleteRappel(id);
      if (success) {
        await loadRappels(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression du rappel: $e');
      return false;
    }
  }

  Future<bool> toggleRappel(String id) async {
    _clearError();
    
    try {
      final success = await _databaseService.toggleRappel(id);
      if (success) {
        await loadRappels(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors du changement de statut du rappel: $e');
      return false;
    }
  }

  // ==================== ÉTATS SANTÉ ====================

  Future<void> loadEtatsSante() async {
    _setLoading(true);
    _clearError();
    
    try {
      _etatsSante = await _databaseService.getEtatsSante();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des états de santé: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addEtatSante(EtatSante etat) async {
    _clearError();
    
    try {
      final success = await _databaseService.addEtatSante(etat);
      if (success) {
        await loadEtatsSante(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de l\'ajout de l\'état de santé: $e');
      return false;
    }
  }

  Future<bool> updateEtatSante(EtatSante etat) async {
    _clearError();
    
    try {
      final success = await _databaseService.updateEtatSante(etat);
      if (success) {
        await loadEtatsSante(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de la mise à jour de l\'état de santé: $e');
      return false;
    }
  }

  Future<bool> deleteEtatSante(String id) async {
    _clearError();
    
    try {
      final success = await _databaseService.deleteEtatSante(id);
      if (success) {
        await loadEtatsSante(); // Recharger la liste
      }
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression de l\'état de santé: $e');
      return false;
    }
  }

  // ==================== UTILITAIRES ====================

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String message) {
    if (_error != message) {
      _error = message;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}

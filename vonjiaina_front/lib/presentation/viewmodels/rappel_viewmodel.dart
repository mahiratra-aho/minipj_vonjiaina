import 'package:flutter/material.dart';
import '../../data/repositories/rappel_repository.dart';
import '../../data/models/rappel_model.dart';
import '../../data/models/medicament_model.dart';

class RappelViewModel extends ChangeNotifier {
  final RappelRepository _repository;
  List<RappelModel> _rappels = [];
  List<MedicamentModel> _medicaments = [];
  bool _isLoading = false;
  String? _errorMessage;

  RappelViewModel({RappelRepository? repository})
      : _repository = repository ?? RappelRepository();

  // Getters
  List<RappelModel> get rappels => List.unmodifiable(_rappels);
  List<MedicamentModel> get medicaments => List.unmodifiable(_medicaments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger tous les rappels
  Future<void> loadRappels() async {
    _setLoading(true);
    try {
      _rappels = await _repository.getAllRappels();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des rappels: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Charger les médicaments (pour la liste)
  Future<void> loadMedicaments() async {
    _setLoading(true);
    try {
      // Simuler des médicaments de test
      _medicaments = [
        MedicamentModel(
          id: 1,
          nom: 'Paracétamol',
          description: 'Antidouleur',
          dosage: '500mg',
          prix: 5.99,
          quantite: 20,
        ),
        MedicamentModel(
          id: 2,
          nom: 'Ibuprofène',
          description: 'Anti-inflammatoire',
          dosage: '400mg',
          prix: 7.50,
          quantite: 15,
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des médicaments: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter un rappel
  Future<void> addRappel({
    required int medicamentId,
    required TimeOfDay heure,
    required List<int> joursRepetition,
    String? messagePersonnalise,
  }) async {
    _setLoading(true);
    try {
      final rappel = RappelModel(
        id: DateTime.now().millisecondsSinceEpoch,
        medicamentId: medicamentId,
        heure:
            '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}',
        joursRepetition: joursRepetition,
        messagePersonnalise: messagePersonnalise,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _repository.createRappel(rappel);
      _rappels.add(rappel);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du rappel: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour un rappel
  Future<void> updateRappel(RappelModel rappel) async {
    _setLoading(true);
    try {
      await _repository.updateRappel(rappel);
      final index = _rappels.indexWhere((r) => r.id == rappel.id);
      if (index != -1) {
        _rappels[index] = rappel;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du rappel: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer un rappel
  Future<void> deleteRappel(int rappelId) async {
    _setLoading(true);
    try {
      await _repository.deleteRappel(rappelId);
      _rappels.removeWhere((r) => r.id == rappelId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du rappel: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer un médicament
  Future<void> deleteMedicament(int medicamentId) async {
    _setLoading(true);
    try {
      // Supprimer tous les rappels associés à ce médicament
      final rappelsToDelete =
          _rappels.where((r) => r.medicamentId == medicamentId).toList();
      for (final rappel in rappelsToDelete) {
        await _repository.deleteRappel(rappel.id);
      }

      // Supprimer le médicament de la liste
      _medicaments.removeWhere((m) => m.id == medicamentId);
      _rappels.removeWhere((r) => r.medicamentId == medicamentId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du médicament: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Activer/Désactiver un rappel
  Future<void> toggleRappel(RappelModel rappel) async {
    final updatedRappel = rappel.copyWith(isActive: !rappel.isActive);
    await updateRappel(updatedRappel);
  }

  // Activer/Désactiver un rappel (alias pour compatibilité)
  Future<void> toggleRappelActivation(RappelModel rappel) async {
    await toggleRappel(rappel);
  }

  // Obtenir les rappels pour un médicament spécifique
  List<RappelModel> getRappelsForMedicament(int medicamentId) {
    return _rappels.where((r) => r.medicamentId == medicamentId).toList();
  }

  // Obtenir les rappels actifs
  List<RappelModel> get activeRappels {
    return _rappels.where((r) => r.isActive).toList();
  }

  // Vider les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper pour setter le loading
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}

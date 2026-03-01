import '../models/rappel_model.dart';

class RappelRepository {
  // Simulation de base de données locale
  static final List<RappelModel> _rappels = [];

  // Obtenir tous les rappels
  Future<List<RappelModel>> getAllRappels() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_rappels);
  }

  // Créer un nouveau rappel
  Future<void> createRappel(RappelModel rappel) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));

    // Vérifier si le rappel existe déjà
    if (_rappels.any((r) => r.id == rappel.id)) {
      throw Exception('Un rappel avec cet ID existe déjà');
    }

    _rappels.add(rappel);
  }

  // Mettre à jour un rappel
  Future<void> updateRappel(RappelModel rappel) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _rappels.indexWhere((r) => r.id == rappel.id);
    if (index == -1) {
      throw Exception('Rappel non trouvé');
    }

    _rappels[index] = rappel.copyWith(updatedAt: DateTime.now());
  }

  // Supprimer un rappel
  Future<void> deleteRappel(int rappelId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));

    final initialLength = _rappels.length;
    _rappels.removeWhere((r) => r.id == rappelId);

    if (_rappels.length == initialLength) {
      throw Exception('Rappel non trouvé');
    }
  }

  // Obtenir les rappels pour un médicament spécifique
  Future<List<RappelModel>> getRappelsByMedicament(int medicamentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rappels.where((r) => r.medicamentId == medicamentId).toList();
  }

  // Obtenir les rappels actifs
  Future<List<RappelModel>> getActiveRappels() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rappels.where((r) => r.isActive).toList();
  }

  // Obtenir les rappels pour aujourd'hui
  Future<List<RappelModel>> getRappelsForToday() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final aujourdHui = DateTime.now().weekday; // 1 = Lundi, 7 = Dimanche
    return _rappels
        .where((r) => r.isActive && r.joursRepetition.contains(aujourdHui))
        .toList();
  }

  // Vider tous les rappels (pour les tests)
  Future<void> clearAllRappels() async {
    _rappels.clear();
  }

  // Initialiser avec des données de test
  Future<void> initializeTestData() async {
    if (_rappels.isEmpty) {
      final testRappels = [
        RappelModel(
          id: 1,
          medicamentId: 1,
          heure: '08:00',
          joursRepetition: [1, 2, 3, 4, 5], // Lundi au Vendredi
          messagePersonnalise: 'Prends ton médicament avant le petit-déjeuner',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        RappelModel(
          id: 2,
          medicamentId: 2,
          heure: '20:00',
          joursRepetition: [1, 3, 5], // Lundi, Mercredi, Vendredi
          messagePersonnalise: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      for (final rappel in testRappels) {
        _rappels.add(rappel);
      }
    }
  }
}

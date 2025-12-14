import '../models/pharmacie_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'package:logging/logging.dart';

class PharmacieRepository {
  static final Logger _logger = Logger('PharmacieRepository');
  final ApiService _apiService;

  PharmacieRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<List<PharmacieModel>> searchPharmacies({
    required String medicament,
    required double latitude,
    required double longitude,
    double rayonKm = 10.0,
    String? statut,
  }) async {
    try {
      final queryParams = {
        'medicament': medicament,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'rayon_km': rayonKm.toString(),
      };

      if (statut != null && statut.isNotEmpty) {
        queryParams['statut'] = statut;
      }

      final response = await _apiService.get(
        ApiConstants.searchPharmacies,
        queryParams: queryParams,
      );

      if (response is Map && response['resultats'] is List) {
        return (response['resultats'] as List)
            .map((json) => PharmacieModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      _logger.severe('Erreur lors de la recherche des pharmacies', e);
      rethrow;
    }
  }
}

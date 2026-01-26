import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/pharmacie_model.dart';
import '../../data/repositories/pharmacie_repository.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/helpers.dart';

enum SearchState { initial, loadingLocation, loading, success, error, empty }

enum FilterType { all, garde, ouverte }

class SearchViewModel extends ChangeNotifier {
  final PharmacieRepository _repository;
  final LocationService _locationService;

  SearchViewModel({
    required PharmacieRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService;

  // State
  SearchState _state = SearchState.initial;
  List<PharmacieModel> _allPharmacies = [];
  List<PharmacieModel> _filteredPharmacies = [];
  String? _errorMessage;
  Position? _currentPosition;
  String _searchQuery = '';
  FilterType _currentFilter = FilterType.all;

  // Getters
  SearchState get state => _state;
  List<PharmacieModel> get pharmacies => _filteredPharmacies;
  String? get errorMessage => _errorMessage;
  Position? get currentPosition => _currentPosition;
  String get searchQuery => _searchQuery;
  FilterType get currentFilter => _currentFilter;

  bool get hasResults => _filteredPharmacies.isNotEmpty;
  bool get isLoading =>
      _state == SearchState.loading || _state == SearchState.loadingLocation;

  Future<void> searchWithAutoLocation(String medicament) async {
    if (medicament.trim().isEmpty) {
      _errorMessage = 'Veuillez entrer un nom de médicament';
      _state = SearchState.error;
      notifyListeners();
      return;
    }

    try {
      // 1. Récupérer position GPS
      _state = SearchState.loadingLocation;
      _searchQuery = medicament;
      _errorMessage = null;
      notifyListeners();

      _currentPosition = await _locationService.getCurrentPosition();

      if (_currentPosition == null) {
        _state = SearchState.error;
        _errorMessage =
            '📍 Impossible d\'obtenir votre position.\nActivez le GPS et réessayez.';
        notifyListeners();
        return;
      }

      // 2. Rechercher toutes les pharmacies
      _state = SearchState.loading;
      notifyListeners();

      _allPharmacies = await _repository.searchPharmacies(
        medicament: medicament,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        rayonKm: 10.0,
      );

      // Calculer les distances si elles ne sont pas déjà fournies par l'API
      _allPharmacies = _allPharmacies.map((pharmacie) {
        if (pharmacie.distanceKm == null) {
          final distance = LocationHelper.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            pharmacie.latitude,
            pharmacie.longitude,
          );
          return pharmacie.copyWith(distanceKm: distance);
        }
        return pharmacie;
      }).toList();

      // 3. Appliquer le filtre actuel
      _applyFilter();

      if (_filteredPharmacies.isEmpty) {
        _state = SearchState.empty;
        _errorMessage = 'Aucune pharmacie trouvée avec "$medicament"';
      } else {
        _state = SearchState.success;
      }
    } catch (e) {
      _state = SearchState.error;
      _errorMessage = 'Erreur : ${e.toString()}';
    }

    notifyListeners();
  }

  void setFilter(FilterType filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    switch (_currentFilter) {
      case FilterType.all:
        _filteredPharmacies = List.from(_allPharmacies);
        break;
      case FilterType.garde:
        _filteredPharmacies =
            _allPharmacies.where((p) => p.statut == 'garde').toList();
        break;
      case FilterType.ouverte:
        _filteredPharmacies = _allPharmacies.where((p) => p.isOuverte).toList();
        break;
    }
  }

  void reset() {
    _state = SearchState.initial;
    _allPharmacies = [];
    _filteredPharmacies = [];
    _errorMessage = null;
    _searchQuery = '';
    _currentFilter = FilterType.all;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/pharmacie_model.dart';
import '../../data/repositories/pharmacie_repository.dart';
import '../../core/services/location_service.dart';
import '../../core/services/error_service.dart';

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
      final error = AppError(
        userMessage: 'Veuillez entrer un nom de médicament',
        technicalMessage: 'Empty search query',
        type: ErrorType.validation,
      );
      _errorMessage = error.userMessage;
      _state = SearchState.error;
      ErrorService.logError(error,
          context: 'SearchViewModel.searchWithAutoLocation');
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
        final error = AppError(
          userMessage:
              'Impossible d\'obtenir votre position\nActivez le GPS et réessayez',
          technicalMessage: 'Location service returned null position',
          type: ErrorType.location,
        );
        _state = SearchState.error;
        _errorMessage = error.userMessage;
        ErrorService.logError(error,
            context: 'SearchViewModel.searchWithAutoLocation');
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

      // 3. Appliquer le filtre actuel
      _applyFilter();

      if (_filteredPharmacies.isEmpty) {
        _state = SearchState.empty;
        _errorMessage =
            'Aucune pharmacie trouvée avec "$medicament"\nEssayez un autre nom de médicament';
      } else {
        _state = SearchState.success;
      }
    } catch (e) {
      final appError = ErrorService.handleError(e);
      _state = SearchState.error;
      _errorMessage = appError.userMessage;
      ErrorService.logError(appError,
          context: 'SearchViewModel.searchWithAutoLocation');
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

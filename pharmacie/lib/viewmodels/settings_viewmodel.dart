import 'package:flutter/foundation.dart';
import '../models/pharmacy_model.dart';

class SettingsViewModel extends ChangeNotifier {
  final bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditing = false;

  // Données vides — remplies après connexion via initFromUser()
  String _managerName = '';
  String _managerRole = '';
  String _pharmacyName = '';
  String _email = '';
  String _address = '';
  String _phone = '';

  List<OpeningHours> _openingHours = PharmacyModel.defaultHours;
  List<PharmacyService> _services = PharmacyModel.defaultServices;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _successMessage;
  String? _errorMessage;

  // Rôles disponibles (partagés avec step1)
  static const List<String> availableRoles = [
    'Pharmacien Titulaire',
    'Pharmacien Adjoint',
    'Assistant Administratif',
    'Responsable Stock',
    'Gérant',
  ];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isEditing => _isEditing;
  String get managerName => _managerName;
  String get managerRole => _managerRole;
  String get pharmacyName => _pharmacyName;
  String get email => _email;
  String get address => _address;
  String get phone => _phone;
  List<OpeningHours> get openingHours => _openingHours;
  List<PharmacyService> get services => _services;
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  bool get currentPasswordVisible => _currentPasswordVisible;
  bool get newPasswordVisible => _newPasswordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  // ── Initialisation depuis le compte connecté (appelé après login) ─────────
  // Point 2 : synchronise les données d'inscription dans les paramètres
  void initFromUser({
    required String name,
    required String role,
    required String email,
    String pharmacyName = '',
    String address = '',
    String phone = '',
    List<OpeningHours>? openingHours,
    List<PharmacyService>? services,
  }) {
    _managerName = name;
    _managerRole = role;
    _email = email;
    _pharmacyName = pharmacyName;
    _address = address;
    _phone = phone;
    if (openingHours != null) {
      _openingHours = openingHours;
    }
    if (services != null) {
      _services = services;
    }
    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  void setEditing(bool val) {
    _isEditing = val;
    notifyListeners();
  }

  void setManagerName(String val) {
    _managerName = val;
    notifyListeners();
  }

  void setManagerRole(String val) {
    _managerRole = val;
    notifyListeners();
  }

  void setPharmacyName(String val) {
    _pharmacyName = val;
    notifyListeners();
  }

  void setEmail(String val) {
    _email = val;
    notifyListeners();
  }

  void setAddress(String val) {
    _address = val;
    notifyListeners();
  }

  void setPhone(String val) {
    _phone = val;
    notifyListeners();
  }

  void updateOpeningHours(int index, OpeningHours hours) {
    _openingHours = List.from(_openingHours)..[index] = hours;
    notifyListeners();
  }

  void toggleService(String id) {
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _services[idx].isEnabled = !_services[idx].isEnabled;
      notifyListeners();
    }
  }

  void setCurrentPassword(String val) {
    _currentPassword = val;
    notifyListeners();
  }

  void setNewPassword(String val) {
    _newPassword = val;
    notifyListeners();
  }

  void setConfirmPassword(String val) {
    _confirmPassword = val;
    notifyListeners();
  }

  void toggleCurrentPasswordVisible() {
    _currentPasswordVisible = !_currentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisible() {
    _newPasswordVisible = !_newPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisible() {
    _confirmPasswordVisible = !_confirmPasswordVisible;
    notifyListeners();
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────
  Future<bool> saveSettings() async {
    _isSaving = true;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isSaving = false;
    _isEditing = false;
    _successMessage = 'Paramètres enregistrés avec succès.';
    notifyListeners();
    return true;
  }

  Future<bool> updatePassword() async {
    _errorMessage = null;
    if (_currentPassword.isEmpty) {
      _errorMessage = 'Veuillez saisir votre mot de passe actuel.';
      notifyListeners();
      return false;
    }
    if (_newPassword.isEmpty) {
      _errorMessage = 'Veuillez saisir un nouveau mot de passe.';
      notifyListeners();
      return false;
    }
    if (_newPassword != _confirmPassword) {
      _errorMessage = 'Les mots de passe ne correspondent pas.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));

    _isSaving = false;
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    _successMessage = 'Mot de passe mis à jour avec succès.';
    notifyListeners();
    return true;
  }

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Point 1 : réinitialise toutes les données du compte
  void resetAllData() {
    _managerName = '';
    _managerRole = '';
    _pharmacyName = '';
    _email = '';
    _address = '';
    _phone = '';
    _openingHours = PharmacyModel.defaultHours;
    _services = PharmacyModel.defaultServices;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }
}

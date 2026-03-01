import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/pharmacy_model.dart';

enum AuthStatus { idle, loading, success, error }

// Stocke toutes les données d'un compte enregistré
class _Account {
  final String email;
  final String password;
  final UserModel user;
  // Données pharmacie — sauvegardées à l'inscription, restaurées au login
  final String pharmacyName;
  final String address;
  final String addressComplement;
  final String phone;
  final String emergencyPhone;
  final List<OpeningHours> openingHours;
  final List<PharmacyService> services;

  const _Account({
    required this.email,
    required this.password,
    required this.user,
    this.pharmacyName = '',
    this.address = '',
    this.addressComplement = '',
    this.phone = '',
    this.emergencyPhone = '',
    this.openingHours = const [],
    this.services = const [],
  });
}

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _currentUser;

  // Base de comptes en mémoire
  final List<_Account> _accounts = [];

  // Login form
  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _passwordVisible = false;

  // Register step 1
  String _fullName = '';
  String _role = '';
  String _pharmacyName = '';
  String _address = '';
  String _addressComplement = '';
  String _proEmail = '';
  String _phone = '';
  String _emergencyPhone = '';

  // Register step 2
  List<OpeningHours> _openingHours = PharmacyModel.defaultHours;
  List<PharmacyService> _services = PharmacyModel.defaultServices;

  // Register step 3
  String _newPassword = '';
  String _confirmPassword = '';
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptCGU = false;
  bool _acceptPrivacy = false;
  bool _certifyInfo = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String get email => _email;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get passwordVisible => _passwordVisible;
  String get fullName => _fullName;
  String get role => _role;
  String get pharmacyName => _pharmacyName;
  String get address => _address;
  String get addressComplement => _addressComplement;
  String get proEmail => _proEmail;
  String get phone => _phone;
  String get emergencyPhone => _emergencyPhone;
  List<OpeningHours> get openingHours => List.unmodifiable(_openingHours);
  List<PharmacyService> get services => _services;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  bool get newPasswordVisible => _newPasswordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  bool get acceptCGU => _acceptCGU;
  bool get acceptPrivacy => _acceptPrivacy;
  bool get certifyInfo => _certifyInfo;

  // ── Force du mot de passe ─────────────────────────────────────────────────
  Map<String, bool> get passwordRequirements => {
    '8 caractères minimum': _newPassword.length >= 8,
    '1 majuscule': _newPassword.contains(RegExp(r'[A-Z]')),
    '1 minuscule': _newPassword.contains(RegExp(r'[a-z]')),
    '1 chiffre': _newPassword.contains(RegExp(r'[0-9]')),
    '1 caractère spécial': _newPassword.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    ),
  };

  double get passwordStrength {
    final met = passwordRequirements.values.where((v) => v).length;
    return met / passwordRequirements.length;
  }

  String get passwordStrengthLabel {
    final s = passwordStrength;
    if (s < 0.4) return 'Faible';
    if (s < 0.7) return 'Moyen';
    return 'Fort';
  }

  bool get canSubmitRegisterStep3 =>
      _acceptCGU &&
      _acceptPrivacy &&
      _certifyInfo &&
      _newPassword == _confirmPassword &&
      passwordStrength >= 0.6;

  // ── Setters login ──────────────────────────────────────────────────────────
  void setEmail(String v) {
    _email = v.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    _errorMessage = null;
    notifyListeners();
  }

  void setRememberMe(bool v) {
    _rememberMe = v;
    notifyListeners();
  }

  void togglePasswordVisible() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  // ── Setters inscription ────────────────────────────────────────────────────
  void setFullName(String v) {
    _fullName = v;
    notifyListeners();
  }

  void setRole(String v) {
    _role = v;
    notifyListeners();
  }

  void setPharmacyName(String v) {
    _pharmacyName = v;
    notifyListeners();
  }

  void setAddress(String v) {
    _address = v;
    notifyListeners();
  }

  void setAddressComplement(String v) {
    _addressComplement = v;
    notifyListeners();
  }

  void setProEmail(String v) {
    _proEmail = v.trim();
    notifyListeners();
  }

  void setPhone(String v) {
    _phone = v;
    notifyListeners();
  }

  void setEmergencyPhone(String v) {
    _emergencyPhone = v;
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

  void setNewPassword(String v) {
    _newPassword = v;
    notifyListeners();
  }

  void setConfirmPassword(String v) {
    _confirmPassword = v;
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

  void setAcceptCGU(bool v) {
    _acceptCGU = v;
    notifyListeners();
  }

  void setAcceptPrivacy(bool v) {
    _acceptPrivacy = v;
    notifyListeners();
  }

  void setCertifyInfo(bool v) {
    _certifyInfo = v;
    notifyListeners();
  }

  // ── Connexion avec erreurs précises ───────────────────────────────────────
  Future<bool> login() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (_email.isEmpty && _password.isEmpty) {
      _errorMessage = 'Veuillez saisir votre email et votre mot de passe.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (_email.isEmpty) {
      _errorMessage = 'Veuillez saisir votre adresse email.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (_password.isEmpty) {
      _errorMessage = 'Veuillez saisir votre mot de passe.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    final matches = _accounts
        .where((a) => a.email.toLowerCase() == _email.toLowerCase())
        .toList();

    if (matches.isEmpty) {
      _errorMessage =
          "Aucun compte trouvé avec cet email. Vérifiez l'adresse ou créez un compte.";
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    if (matches.first.password != _password) {
      _errorMessage = 'Mot de passe incorrect. Veuillez réessayer.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    final account = matches.first;
    _currentUser = account.user;

    // Restaurer les données pharmacie saisies à l'inscription
    _pharmacyName = account.pharmacyName;
    _address = account.address;
    _addressComplement = account.addressComplement;
    _phone = account.phone;
    _emergencyPhone = account.emergencyPhone;
    _openingHours = List.from(account.openingHours);
    _services = List.from(account.services);

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  // ── Inscription — sauvegarde toutes les données en mémoire ────────────────
  Future<bool> register() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final exists = _accounts.any(
      (a) => a.email.toLowerCase() == _proEmail.toLowerCase(),
    );
    if (exists) {
      _errorMessage = 'Un compte existe déjà avec cet email.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullName,
      email: _proEmail,
      role: _role,
    );

    // Sauvegarder TOUTES les données saisies dans le compte
    _accounts.add(
      _Account(
        email: _proEmail,
        password: _newPassword,
        user: newUser,
        pharmacyName: _pharmacyName,
        address: _address,
        addressComplement: _addressComplement,
        phone: _phone,
        emergencyPhone: _emergencyPhone,
        openingHours: List.from(_openingHours),
        services: List.from(_services),
      ),
    );

    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _email = '';
    _password = '';
    _pharmacyName = '';
    _address = '';
    _addressComplement = '';
    _phone = '';
    _emergencyPhone = '';
    _openingHours = PharmacyModel.defaultHours;
    _services = PharmacyModel.defaultServices;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Remet à zéro le formulaire d'inscription (après redirect vers login)
  void resetRegistration() {
    _fullName = '';
    _role = '';
    _pharmacyName = '';
    _address = '';
    _addressComplement = '';
    _proEmail = '';
    _phone = '';
    _emergencyPhone = '';
    _openingHours = PharmacyModel.defaultHours;
    _services = PharmacyModel.defaultServices;
    _newPassword = '';
    _confirmPassword = '';
    _newPasswordVisible = false;
    _confirmPasswordVisible = false;
    _acceptCGU = false;
    _acceptPrivacy = false;
    _certifyInfo = false;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

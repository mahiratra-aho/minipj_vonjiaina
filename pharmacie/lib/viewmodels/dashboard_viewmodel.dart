import 'package:flutter/foundation.dart';
import '../models/medication_model.dart';
import '../models/activity_log_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final List<MedicationModel> _allMedications;

  bool _showAlert = true;
  bool _isOnGuard = false;
  bool _guardDialogShown = false;

  final List<ActivityLogModel> _recentActivities = [];

  DashboardViewModel(this._allMedications);

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get showAlert => _showAlert;
  bool get isOnGuard => _isOnGuard;
  bool get guardDialogShown => _guardDialogShown;

  int get totalMedications => _allMedications.length;

  // Point 9 : stock faible = en dessous du seuil minimum
  List<MedicationModel> get lowStockMedications =>
      _allMedications.where((m) => m.isCritical).toList();

  int get lowStockCount => lowStockMedications.length;

  // Point 9 : bientôt expiré = année+mois <= aujourd'hui (dans le mois courant ou déjà passé)
  List<MedicationModel> get expiringMedications {
    final now = DateTime.now();
    return _allMedications.where((m) {
      final exp = m.expiryDate;
      // Expiré si la date est supérieure à 1 mois passé par rapport à aujourd'hui
      // Bientôt expiré si année+mois <= aujourd'hui
      final expMonth = DateTime(exp.year, exp.month);
      final nowMonth = DateTime(now.year, now.month);
      return !expMonth.isAfter(nowMonth); // mois d'expiration <= mois actuel
    }).toList();
  }

  int get expiringCount => expiringMedications.length;

  List<ActivityLogModel> get recentActivities => _recentActivities;

  // ── Actions ───────────────────────────────────────────────────────────────
  void dismissAlert() {
    _showAlert = false;
    notifyListeners();
  }

  // Point 5 : switch de garde
  void setOnGuard(bool val) {
    _isOnGuard = val;
    notifyListeners();
  }

  void markGuardDialogShown() {
    _guardDialogShown = true;
    notifyListeners();
  }

  void addActivity(ActivityLogModel activity) {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 20) _recentActivities.removeLast();
    notifyListeners();
  }
}

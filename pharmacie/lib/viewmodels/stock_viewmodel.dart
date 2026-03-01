import 'dart:convert';
import 'dart:io';
//import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/medication_model.dart';

enum StockFilter { all, available, lowStock, expiringSoon, outOfStock }

// Résultat d'un import
class ImportResult {
  final int imported;
  final int errors;
  final List<String> errorMessages;
  const ImportResult({
    required this.imported,
    required this.errors,
    required this.errorMessages,
  });
}

class StockViewModel extends ChangeNotifier {
  bool _isLoading = false;
  StockFilter _activeFilter = StockFilter.all;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Point 8 : liste vide au démarrage — remplie uniquement via import ou ajout manuel
  final List<MedicationModel> _allMedications = [];

  // Formulaire ajout
  String _formName = '';
  MedicationCategory? _formCategory;
  String _formDosage = '';
  int? _formMonth;
  int? _formYear;
  int _formQuantity = 0;
  int _formMinThreshold = 10;
  String _formLotNumber = '';
  double? _formPrice;
  List<String> _nameSuggestions = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  StockFilter get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  String get formName => _formName;
  MedicationCategory? get formCategory => _formCategory;
  String get formDosage => _formDosage;
  int? get formMonth => _formMonth;
  int? get formYear => _formYear;
  int get formQuantity => _formQuantity;
  int get formMinThreshold => _formMinThreshold;
  String get formLotNumber => _formLotNumber;
  double? get formPrice => _formPrice;
  List<String> get nameSuggestions => _nameSuggestions;

  List<MedicationModel> get allMedications =>
      List.unmodifiable(_allMedications);

  int get totalCount => _allMedications.length;
  int get lowStockCount => _allMedications
      .where(
        (m) =>
            m.status == MedicationStatus.lowStock ||
            m.status == MedicationStatus.veryRare,
      )
      .length;
  int get outOfStockCount => _allMedications
      .where((m) => m.status == MedicationStatus.outOfStock)
      .length;

  List<MedicationModel> get filteredMedications {
    var list = _allMedications;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (m) =>
                m.name.toLowerCase().contains(q) ||
                m.category.displayName.toLowerCase().contains(q) ||
                m.lotNumber.toLowerCase().contains(q),
          )
          .toList();
    }

    switch (_activeFilter) {
      case StockFilter.all:
        break;
      case StockFilter.available:
        list = list
            .where((m) => m.status == MedicationStatus.available)
            .toList();
      case StockFilter.lowStock:
        list = list
            .where(
              (m) =>
                  m.status == MedicationStatus.lowStock ||
                  m.status == MedicationStatus.veryRare,
            )
            .toList();
      case StockFilter.expiringSoon:
        list = list.where((m) => m.isExpiringSoon).toList();
      case StockFilter.outOfStock:
        list = list
            .where((m) => m.status == MedicationStatus.outOfStock)
            .toList();
    }

    return list;
  }

  List<MedicationModel> get paginatedMedications {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filteredMedications.length);
    return filteredMedications.sublist(start, end);
  }

  int get totalPages =>
      (filteredMedications.length / _itemsPerPage).ceil().clamp(1, 99999);

  // ── Navigation ────────────────────────────────────────────────────────────
  void setFilter(StockFilter filter) {
    _activeFilter = filter;
    _currentPage = 1;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // ── Formulaire ────────────────────────────────────────────────────────────
  void setFormName(String v) {
    _formName = v;
    _updateSuggestions(v);
    notifyListeners();
  }

  void setFormCategory(MedicationCategory? v) {
    _formCategory = v;
    notifyListeners();
  }

  void setFormDosage(String v) {
    _formDosage = v;
    notifyListeners();
  }

  void setFormMonth(int? v) {
    _formMonth = v;
    notifyListeners();
  }

  void setFormYear(int? v) {
    _formYear = v;
    notifyListeners();
  }

  void setFormQuantity(int v) {
    _formQuantity = v;
    notifyListeners();
  }

  void setFormMinThreshold(int v) {
    _formMinThreshold = v;
    notifyListeners();
  }

  void setFormLotNumber(String v) {
    _formLotNumber = v;
    notifyListeners();
  }

  void setFormPrice(double? v) {
    _formPrice = v;
    notifyListeners();
  }

  void incrementQuantity() {
    _formQuantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_formQuantity > 0) {
      _formQuantity--;
      notifyListeners();
    }
  }

  void _updateSuggestions(String q) {
    if (q.length < 2) {
      _nameSuggestions = [];
      return;
    }
    _nameSuggestions = _allMedications
        .where((m) => m.name.toLowerCase().contains(q.toLowerCase()))
        .map((m) => m.name)
        .toList();
  }

  MedicationModel? getMedicationById(String id) {
    try {
      return _allMedications.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  void loadMedicationForEdit(String id) {
    final med = getMedicationById(id);
    if (med != null) {
      _formName = med.name;
      _formDosage = med.dosage;
      _formCategory = med.category;
      _formQuantity = med.quantity;
      _formMinThreshold = med.minThreshold;
      _formLotNumber = med.lotNumber;
      _formPrice = med.price;
      // Point 9 : NE PAS charger les dates pour éviter la modification
      _formMonth = null;
      _formYear = null;
      notifyListeners();
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<bool> addMedication() async {
    if (_formName.isEmpty ||
        _formCategory == null ||
        _formMonth == null ||
        _formYear == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    _allMedications.add(
      MedicationModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: _formName,
        dosage: _formDosage,
        category: _formCategory!,
        quantity: _formQuantity,
        minThreshold: _formMinThreshold,
        expiryDate: DateTime(_formYear!, _formMonth!),
        lotNumber: _formLotNumber.isEmpty ? 'LOT-MANUEL' : _formLotNumber,
        price: _formPrice,
      ),
    );
    _resetForm();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateMedication(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    final idx = _allMedications.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final med = _allMedications[idx];
      _allMedications[idx] = med.copyWith(
        name: _formName.isNotEmpty ? _formName : null,
        dosage: _formDosage.isNotEmpty ? _formDosage : null,
        category: _formCategory,
        quantity: _formQuantity,
        minThreshold: _formMinThreshold,
        // Point 9 : date d'expiration non modifiable lors d'une édition
      );
    }
    _resetForm();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteMedication(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _allMedications.removeWhere((m) => m.id == id);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void _resetForm() {
    _formName = '';
    _formCategory = null;
    _formDosage = '';
    _formMonth = null;
    _formYear = null;
    _formQuantity = 0;
    _formMinThreshold = 10;
    _formLotNumber = '';
    _formPrice = null;
    _nameSuggestions = [];
  }

  // ── Point 7 : télécharger le modèle CSV ──────────────────────────────────
  Future<String?> downloadTemplateCsv() async {
    const header =
        'nom;dosage;categorie;mois_expiration;annee_expiration;quantite;seuil_minimum;numero_lot;prix\n';
    const example =
        'Amoxicilline 500mg;500mg;Antibiotiques et Antibactériens;12;2027;100;10;LOT-001;2500\n'
        'Paracétamol 1g;1g;Analgésiques et Anti-inflammatoires;6;2028;50;5;LOT-002;1200\n';
    final content = header + example;
    return _saveTextFile('modele_import_vonjiaina.csv', content);
  }

  // ── Point 7 : télécharger le modèle XLSX ─────────────────────────────────
  Future<String?> downloadTemplateXlsx() async {
    final excel = Excel.createExcel();
    final sheet = excel['Médicaments'];
    excel.delete('Sheet1');

    // En-têtes
    final headers = [
      'nom',
      'dosage',
      'categorie',
      'mois_expiration',
      'annee_expiration',
      'quantite',
      'seuil_minimum',
      'numero_lot',
      'prix',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(
        headers[i],
      );
    }

    // Ligne exemple 1
    final ex1 = [
      'Amoxicilline 500mg',
      '500mg',
      'Antibiotiques et Antibactériens',
      '12',
      '2027',
      '100',
      '10',
      'LOT-001',
      '2500',
    ];
    for (var i = 0; i < ex1.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .value = TextCellValue(
        ex1[i],
      );
    }

    // Ligne exemple 2
    final ex2 = [
      'Paracétamol 1g',
      '1g',
      'Analgésiques et Anti-inflammatoires',
      '6',
      '2028',
      '50',
      '5',
      'LOT-002',
      '1200',
    ];
    for (var i = 0; i < ex2.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2))
          .value = TextCellValue(
        ex2[i],
      );
    }

    final bytes = excel.encode();
    if (bytes == null) return null;
    return _saveBinaryFile(
      'modele_import_vonjiaina.xlsx',
      Uint8List.fromList(bytes),
    );
  }

  Future<String?> _saveTextFile(String name, String content) async {
    try {
      if (kIsWeb) return null;
      final dir =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsString(content, encoding: utf8);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _saveBinaryFile(String name, Uint8List bytes) async {
    try {
      if (kIsWeb) return null;
      final dir =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ── Point 8 : import réel CSV / XLSX ─────────────────────────────────────
  Future<ImportResult?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final ext = (file.extension ?? '').toLowerCase();

    _isLoading = true;
    notifyListeners();

    ImportResult importResult;
    if (ext == 'csv') {
      importResult = _parseCsv(utf8.decode(bytes));
    } else {
      importResult = _parseXlsx(bytes);
    }

    _isLoading = false;
    notifyListeners();
    return importResult;
  }

  // ── Parser CSV ────────────────────────────────────────────────────────────
  ImportResult _parseCsv(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const ImportResult(imported: 0, errors: 0, errorMessages: []);
    }

    // Détecter séparateur (virgule ou point-virgule)
    final sep = lines[0].contains(';') ? ';' : ',';

    // Récupérer index des colonnes depuis l'en-tête
    final headers = lines[0]
        .split(sep)
        .map((h) => h.trim().toLowerCase())
        .toList();
    return _parseRows(headers, lines.skip(1).toList(), sep);
  }

  // ── Parser XLSX ───────────────────────────────────────────────────────────
  ImportResult _parseXlsx(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;
    if (sheet.rows.isEmpty) {
      return const ImportResult(imported: 0, errors: 0, errorMessages: []);
    }

    final headerRow = sheet.rows.first;
    final headers = headerRow
        .map((c) => (c?.value?.toString() ?? '').toLowerCase().trim())
        .toList();

    final rows = sheet.rows.skip(1).map((row) {
      return row.map((c) => c?.value?.toString() ?? '').join(';');
    }).toList();

    return _parseRows(headers, rows, ';');
  }

  // ── Traitement commun des lignes ──────────────────────────────────────────
  ImportResult _parseRows(List<String> headers, List<String> rows, String sep) {
    int imported = 0;
    final errors = <String>[];

    // Index des colonnes
    int idx(String name) => headers.indexOf(name);
    final iNom = idx('nom');
    final iDosage = idx('dosage');
    final iCat = idx('categorie');
    final iMois = idx('mois_expiration');
    final iAnnee = idx('annee_expiration');
    final iQte = idx('quantite');
    final iSeuil = idx('seuil_minimum');
    final iLot = idx('numero_lot');
    final iPrix = idx('prix');

    for (var i = 0; i < rows.length; i++) {
      final lineNum = i + 2; // +2 car on a sauté l'en-tête
      final cells = rows[i].split(sep);
      String cell(int index) =>
          (index >= 0 && index < cells.length) ? cells[index].trim() : '';

      final nom = cell(iNom);
      final moisS = cell(iMois);
      final anneeS = cell(iAnnee);
      final qteS = cell(iQte);

      if (nom.isEmpty) {
        errors.add('Ligne $lineNum : nom manquant');
        continue;
      }
      if (moisS.isEmpty) {
        errors.add('Ligne $lineNum : mois manquant');
        continue;
      }
      if (anneeS.isEmpty) {
        errors.add('Ligne $lineNum : année manquante');
        continue;
      }

      final mois = int.tryParse(moisS);
      final annee = int.tryParse(anneeS);
      final qte = int.tryParse(qteS) ?? 0;

      if (mois == null || mois < 1 || mois > 12) {
        errors.add('Ligne $lineNum : mois invalide ($moisS)');
        continue;
      }
      if (annee == null) {
        errors.add('Ligne $lineNum : année invalide ($anneeS)');
        continue;
      }

      // Point 15 : limiter à 5 ans
      final now = DateTime.now();
      if (annee > now.year + 5) {
        errors.add(
          'Ligne $lineNum : année trop lointaine ($annee, max ${now.year + 5})',
        );
        continue;
      }

      final catStr = cell(iCat);
      final cat = catStr.isNotEmpty
          ? MedicationCategoryExt.fromString(catStr)
          : MedicationCategory.analgesicsAntiInflammatory;

      final seuil = int.tryParse(cell(iSeuil)) ?? 10;
      final lot = cell(iLot).isEmpty ? 'LOT-IMP' : cell(iLot);
      final prix = double.tryParse(cell(iPrix));

      // Vérifier si le médicament existe déjà (même nom + lot) — mise à jour
      final existIdx = _allMedications.indexWhere(
        (m) => m.name.toLowerCase() == nom.toLowerCase() && m.lotNumber == lot,
      );
      if (existIdx >= 0) {
        _allMedications[existIdx] = _allMedications[existIdx].copyWith(
          quantity: qte,
        );
      } else {
        _allMedications.add(
          MedicationModel(
            id: 'imp_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: nom,
            dosage: cell(iDosage),
            category: cat,
            quantity: qte,
            minThreshold: seuil,
            expiryDate: DateTime(annee, mois),
            lotNumber: lot,
            price: prix,
          ),
        );
      }
      imported++;
    }

    return ImportResult(
      imported: imported,
      errors: errors.length,
      errorMessages: errors,
    );
  }
}

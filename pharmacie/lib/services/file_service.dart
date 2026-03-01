import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/medication_model.dart';

class FileService {
  static Future<void> downloadCSVTemplate() async {
    final csvData = [
      [
        'Nom du médicament',
        'Dosage',
        'Catégorie',
        'Quantité',
        'Seuil minimum',
        'Mois expiration',
        'Année expiration',
      ],
      [
        'Exemple: Paracétamol',
        '500mg',
        'ANALGÉSIQUES ET ANTI-INFLAMMATOIRES',
        '100',
        '10',
        '12',
        '2025',
      ],
    ];

    String csv = csvData.map((row) => row.join(',')).join('\n');

    final bytes = Uint8List.fromList(utf8.encode(csv));

    await FilePicker.platform.saveFile(
      dialogTitle: 'Télécharger le modèle CSV',
      fileName: 'modele_medicaments.csv',
      bytes: bytes,
    );
  }

  static Future<void> downloadExcelTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Médicaments'];

    // Headers
    sheet.appendRow([
      TextCellValue('Nom du médicament'),
      TextCellValue('Dosage'),
      TextCellValue('Catégorie'),
      TextCellValue('Quantité'),
      TextCellValue('Seuil minimum'),
      TextCellValue('Mois expiration'),
      TextCellValue('Année expiration'),
    ]);

    // Example row
    sheet.appendRow([
      TextCellValue('Exemple: Paracétamol'),
      TextCellValue('500mg'),
      TextCellValue('ANALGÉSIQUES ET ANTI-INFLAMMATOIRES'),
      IntCellValue(100),
      IntCellValue(10),
      IntCellValue(12),
      IntCellValue(2025),
    ]);

    final excelBytes = Uint8List.fromList(excel.save()!);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Télécharger le modèle Excel',
      fileName: 'modele_medicaments.xlsx',
      bytes: excelBytes,
    );
  }

  static Future<List<MedicationModel>> importFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result == null) return [];

    final file = File(result.files.single.path!);
    final extension = result.files.single.extension?.toLowerCase();

    if (extension == 'csv') {
      return await _importFromCSV(file);
    } else if (extension == 'xlsx') {
      return await _importFromExcel(file);
    }

    return [];
  }

  static Future<List<MedicationModel>> _importFromCSV(File file) async {
    final content = await file.readAsString();

    // Parse CSV manually
    List<List<dynamic>> rows = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.split(',').map((cell) => cell.trim()).toList())
        .toList();

    List<MedicationModel> medications = [];

    // Skip header row
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 9) {
        try {
          final medication = MedicationModel(
            id: 'import_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: row[0]?.toString() ?? '',
            dosage: row[1]?.toString() ?? '',
            category: _parseCategory(row[2]?.toString() ?? ''),
            quantity: int.tryParse(row[3]?.toString() ?? '') ?? 0,
            minThreshold: int.tryParse(row[4]?.toString() ?? '') ?? 10,
            expiryDate: DateTime(
              int.tryParse(row[6]?.toString() ?? '') ?? 2025,
              int.tryParse(row[5]?.toString() ?? '') ?? 12,
            ),
            lotNumber: '',
          );
          medications.add(medication);
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }
    }

    return medications;
  }

  static Future<List<MedicationModel>> _importFromExcel(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    List<MedicationModel> medications = [];

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table]!;

      // Skip header row
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.length >= 9) {
          try {
            final medication = MedicationModel(
              id: 'import_${DateTime.now().millisecondsSinceEpoch}_$i',
              name: row[0]?.value?.toString() ?? '',
              dosage: row[1]?.value?.toString() ?? '',
              category: _parseCategory(row[2]?.value?.toString() ?? ''),
              quantity: int.tryParse(row[3]?.value?.toString() ?? '') ?? 0,
              minThreshold: int.tryParse(row[4]?.value?.toString() ?? '') ?? 10,
              expiryDate: DateTime(
                int.tryParse(row[6]?.value?.toString() ?? '') ?? 2025,
                int.tryParse(row[5]?.value?.toString() ?? '') ?? 12,
              ),
              lotNumber: '',
            );
            medications.add(medication);
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }
    }

    return medications;
  }

  static MedicationCategory _parseCategory(String categoryString) {
    final categoryMap = {
      'ANALGÉSIQUES ET ANTI-INFLAMMATOIRES':
          MedicationCategory.analgesicsAntiInflammatory,
      'ANTIBIOTIQUES ET ANTIBACTÉRIENS':
          MedicationCategory.antibioticsAntibacterials,
      'ANTITUBERCULEUX ET ANTILÉPREUX':
          MedicationCategory.antituberculousAntileprosy,
      'ANTIMYCOSIQUES': MedicationCategory.antimycotics,
      'ANTIVIRAUX': MedicationCategory.antiviraux,
      'CARDIOLOGIE': MedicationCategory.cardiologie,
      'DERMATOLOGIE': MedicationCategory.dermatologie,
      'DIÉTÉTIQUE ET NUTRITION': MedicationCategory.dieteticsNutrition,
      'ENDOCRINOLOGIE': MedicationCategory.endocrinologie,
      'GASTRO-ENTÉROLOGIE ET HÉPATOLOGIE':
          MedicationCategory.gastroenterologyHepatology,
      'GYNÉCOLOGIE OBSTÉTRIQUE ET CONTRACEPTION':
          MedicationCategory.gynecologyObstetricsContraception,
      'HÉMATOLOGIE': MedicationCategory.hematologie,
      'IMMUNOLOGIE ET ALLERGOLOGIE': MedicationCategory.immunologyAllergology,
      'MÉDICAMENTS DES TROUBLES MÉTABOLIQUES':
          MedicationCategory.metabolicDisorders,
      'NEUROLOGIE': MedicationCategory.neurologie,
      'OPHTALMOLOGIE': MedicationCategory.ophthalmology,
      'OTO-RHINO-LARYNGOLOGIE': MedicationCategory.otorhinolaryngology,
      'PARASITOLOGIE': MedicationCategory.parasitologie,
      'PNEUMOLOGIE': MedicationCategory.pneumologie,
      'PSYCHIATRIE': MedicationCategory.psychiatrie,
      'RÉANIMATION ET TOXICOLOGIE': MedicationCategory.resuscitationToxicology,
      'RHUMATOLOGIE': MedicationCategory.rheumatology,
      'STOMATOLOGIE': MedicationCategory.stomatologie,
      'UROLOGIE': MedicationCategory.urologie,
      'VACCINS, IMMUNOGLOBULINES, SÉROTHÉRAPIE':
          MedicationCategory.vaccinesImunoglobulinsSerotherapy,
      'CANCÉROLOGIE': MedicationCategory.oncology,
      'ANESTHÉSIQUES LOCAUX': MedicationCategory.localAnesthetics,
      'ANTIACIDES': MedicationCategory.antiacides,
      'ANTAGONISTES DU CALCIUM': MedicationCategory.calciumAntagonists,
      'ANTIAGRÉGANTS PLAQUETTAIRES': MedicationCategory.antiplateletAgents,
      'ANTIARYTHMIQUES': MedicationCategory.antiarrhythmics,
      'ANTICHOLINERGIQUES': MedicationCategory.anticholinergics,
      'ANTIÉPILEPTIQUES': MedicationCategory.antiepileptics,
      'ANTICOAGULANTS CIRCULANTS': MedicationCategory.circulatingAnticoagulants,
      'ANTICOAGULANTS DE TYPE AVK': MedicationCategory.avkAnticoagulants,
      'ANTIDIARRHÉIQUES': MedicationCategory.antidiarrheals,
      'ANTIHISTAMINIQUES H1': MedicationCategory.h1Antihistamines,
      'ANTIHISTAMINIQUES H2': MedicationCategory.h2Antihistamines,
      'ANTIHYPERTENSEURS': MedicationCategory.antihypertensives,
      'ANTIPSYCHOTIQUES': MedicationCategory.antipsychotics,
      'ANTISPASMODIQUES': MedicationCategory.antispasmodics,
      'ANTITHYROÏDIENS DE SYNTHÈSE':
          MedicationCategory.syntheticAntithyroidians,
      'ANXIOLYTIQUES': MedicationCategory.anxiolytics,
      'BÊTA-BLOQUANTS': MedicationCategory.betaBlockers,
      'CARDIOTONIQUES': MedicationCategory.cardiotonics,
      'DIURÉTIQUES': MedicationCategory.diuretics,
      'HYPNOTIQUES': MedicationCategory.hypnotics,
      'HYPOGLYCÉMIANTS INJECTABLES': MedicationCategory.injectableHypoglycemics,
      'HYPOGLYCÉMIANTS ORAUX': MedicationCategory.oralHypoglycemics,
      'HYPOLIPÉMIANTS': MedicationCategory.hypolipemiants,
      'INHIBITEURS DE L\'ENZYME DE CONVERSION':
          MedicationCategory.aceInhibitors,
      'INHIBITEURS DE L\'ANGIOTENSINE II':
          MedicationCategory.angiotensinIiInhibitors,
      'MUCOLYTIQUES': MedicationCategory.mucolytics,
      'NOOTROPIQUES': MedicationCategory.nootropics,
      'PHÉNYLÉTHYLAMINES': MedicationCategory.phenylethylamines,
      'SARTANS (ANTAGONISTES DE L\'ANGIOTENSINE II)':
          MedicationCategory.sartans,
      'TRIPTANS': MedicationCategory.triptans,
    };

    return categoryMap[categoryString.toUpperCase()] ??
        MedicationCategory.other;
  }
}

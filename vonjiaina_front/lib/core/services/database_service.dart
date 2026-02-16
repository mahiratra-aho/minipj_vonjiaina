import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';
import '../constants/app_colors.dart';
import '../../data/models/health_models.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  static final _log = Logger('DatabaseService');
  static const String _databaseName = 'vonjiaina_health.db';
  static const int _databaseVersion = 1;

  // Tables
  static const String tableRappels = 'rappels';
  static const String tableEtatsSante = 'etats_sante';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _log.info('Initialisation de la base de données: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    _log.info('Création des tables de la base de données');

    // Créer la table des rappels
    await db.execute('''
      CREATE TABLE $tableRappels (
        id TEXT PRIMARY KEY,
        nom_medicament TEXT NOT NULL,
        notes TEXT,
        heure INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        date_creation INTEGER NOT NULL
      )
    ''');

    // Créer la table des états de santé
    await db.execute('''
      CREATE TABLE $tableEtatsSante (
        id TEXT PRIMARY KEY,
        humeur TEXT NOT NULL,
        notes TEXT,
        date INTEGER NOT NULL
      )
    ''');

    _log.info('Tables créées avec succès');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _log.info(
        'Mise à jour de la base de données de $oldVersion vers $newVersion');

    if (oldVersion < newVersion) {
      // Pour les futures migrations
      await db.execute('DROP TABLE IF EXISTS $tableRappels');
      await db.execute('DROP TABLE IF EXISTS $tableEtatsSante');
      await _onCreate(db, newVersion);
    }
  }

  // ==================== RAPPELS ====================

  Future<List<MedicamentRappel>> getRappels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableRappels, orderBy: 'date_creation DESC');

    return List.generate(maps.length, (i) {
      final hour = maps[i]['heure'] as int? ?? 9;
      final minute = maps[i]['minute'] as int? ?? 0;

      return MedicamentRappel(
        id: maps[i]['id'],
        nomMedicament: maps[i]['nom_medicament'],
        notes: maps[i]['notes'],
        heure: TimeOfDay(hour: hour, minute: minute),
        isActive: maps[i]['is_active'] == 1,
        dateCreation:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['date_creation']),
      );
    });
  }

  Future<bool> addRappel(MedicamentRappel rappel) async {
    try {
      final db = await database;
      await db.insert(
        tableRappels,
        {
          'id': rappel.id,
          'nom_medicament': rappel.nomMedicament,
          'notes': rappel.notes,
          'heure': rappel.heure.hour,
          'minute': rappel.heure.minute,
          'is_active': rappel.isActive ? 1 : 0,
          'date_creation': rappel.dateCreation.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _log.info('Rappel ajouté: ${rappel.nomMedicament}');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de l\'ajout du rappel: $e');
      return false;
    }
  }

  Future<bool> updateRappel(MedicamentRappel rappel) async {
    try {
      final db = await database;
      await db.update(
        tableRappels,
        {
          'nom_medicament': rappel.nomMedicament,
          'notes': rappel.notes,
          'heure': rappel.heure.hour,
          'minute': rappel.heure.minute,
          'is_active': rappel.isActive ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [rappel.id],
      );

      _log.info('Rappel mis à jour: ${rappel.nomMedicament}');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de la mise à jour du rappel: $e');
      return false;
    }
  }

  Future<bool> deleteRappel(String id) async {
    try {
      final db = await database;
      await db.delete(
        tableRappels,
        where: 'id = ?',
        whereArgs: [id],
      );

      _log.info('Rappel supprimé: $id');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de la suppression du rappel: $e');
      return false;
    }
  }

  Future<bool> toggleRappel(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        tableRappels,
        columns: ['is_active'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final currentStatus = result.first['is_active'] == 1;
        await db.update(
          tableRappels,
          {'is_active': currentStatus ? 0 : 1},
          where: 'id = ?',
          whereArgs: [id],
        );

        _log.info('Rappel ${currentStatus ? "désactivé" : "activé"}: $id');
        return true;
      }

      return false;
    } catch (e) {
      _log.severe('Erreur lors du changement de statut du rappel: $e');
      return false;
    }
  }

  // ==================== ÉTATS SANTÉ ====================

  Future<List<EtatSante>> getEtatsSante() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableEtatsSante, orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      final humeurString = maps[i]['humeur'];
      return EtatSante(
        id: maps[i]['id'],
        humeur: Humeur.values.firstWhere((h) => h.toString() == humeurString),
        notes: maps[i]['notes'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date']),
      );
    });
  }

  Future<bool> addEtatSante(EtatSante etat) async {
    try {
      final db = await database;
      await db.insert(
        tableEtatsSante,
        {
          'id': etat.id,
          'humeur': etat.humeur.toString(),
          'notes': etat.notes,
          'date': etat.date.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _log.info('État de santé ajouté: ${etat.humeur.label}');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de l\'ajout de l\'état de santé: $e');
      return false;
    }
  }

  Future<bool> updateEtatSante(EtatSante etat) async {
    try {
      final db = await database;
      await db.update(
        tableEtatsSante,
        {
          'humeur': etat.humeur.toString(),
          'notes': etat.notes,
        },
        where: 'id = ?',
        whereArgs: [etat.id],
      );

      _log.info('État de santé mis à jour: ${etat.humeur.label}');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de la mise à jour de l\'état de santé: $e');
      return false;
    }
  }

  Future<bool> deleteEtatSante(String id) async {
    try {
      final db = await database;
      await db.delete(
        tableEtatsSante,
        where: 'id = ?',
        whereArgs: [id],
      );

      _log.info('État de santé supprimé: $id');
      return true;
    } catch (e) {
      _log.severe('Erreur lors de la suppression de l\'état de santé: $e');
      return false;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _log.info('Base de données fermée');
    }
  }
}

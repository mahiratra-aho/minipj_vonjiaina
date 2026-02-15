import 'package:flutter/material.dart';

enum Humeur {
  tresBien('Très bien', '😊', Colors.green),
  bien('Bien', '🙂', Colors.lightGreen),
  neutre('Neutre', '😐', Colors.yellow),
  fatigue('Fatigué', '😔', Colors.orange),
  malade('Malade', '😷', Colors.red);

  const Humeur(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;
}

class MedicamentRappel {
  final String id;
  final String nomMedicament;
  final String? notes;
  final TimeOfDay heure;
  final bool isActive;
  final DateTime dateCreation;

  MedicamentRappel({
    required this.id,
    required this.nomMedicament,
    this.notes,
    required this.heure,
    required this.isActive,
    required this.dateCreation,
  });

  factory MedicamentRappel.fromJson(Map<String, dynamic> json) {
    return MedicamentRappel(
      id: json['id']?.toString() ?? '',
      nomMedicament: json['nom_medicament'] ?? '',
      notes: json['notes'],
      heure: _parseTime(json['heure']),
      isActive: json['is_active'] ?? true,
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_medicament': nomMedicament,
      'notes': notes,
      'heure':
          '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}',
      'is_active': isActive,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  static TimeOfDay _parseTime(dynamic time) {
    if (time is String) {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String get formattedHeure {
    return '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${dateCreation.day.toString().padLeft(2, '0')}/${dateCreation.month.toString().padLeft(2, '0')}/${dateCreation.year}';
  }

  MedicamentRappel copyWith({
    String? id,
    String? nomMedicament,
    String? notes,
    TimeOfDay? heure,
    bool? isActive,
    DateTime? dateCreation,
  }) {
    return MedicamentRappel(
      id: id ?? this.id,
      nomMedicament: nomMedicament ?? this.nomMedicament,
      notes: notes ?? this.notes,
      heure: heure ?? this.heure,
      isActive: isActive ?? this.isActive,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}

class EtatSante {
  final String id;
  final Humeur humeur;
  final String? notes;
  final DateTime date;
  final List<String> symptomes;

  EtatSante({
    required this.id,
    required this.humeur,
    this.notes,
    required this.date,
    this.symptomes = const [],
  });

  factory EtatSante.fromJson(Map<String, dynamic> json) {
    return EtatSante(
      id: json['id']?.toString() ?? '',
      humeur: Humeur.values.firstWhere(
        (h) => h.name == json['humeur'],
        orElse: () => Humeur.neutre,
      ),
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      symptomes: List<String>.from(json['symptomes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'humeur': humeur.name,
      'notes': notes,
      'date': date.toIso8601String(),
      'symptomes': symptomes,
    };
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

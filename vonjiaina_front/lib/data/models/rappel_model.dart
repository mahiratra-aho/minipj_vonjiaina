class RappelModel {
  final int id;
  final int medicamentId;
  final String heure;
  final List<int> joursRepetition;
  final String? messagePersonnalise;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RappelModel({
    required this.id,
    required this.medicamentId,
    required this.heure,
    required this.joursRepetition,
    this.messagePersonnalise,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  // Constructeur pour créer un rappel depuis JSON
  factory RappelModel.fromJson(Map<String, dynamic> json) {
    return RappelModel(
      id: json['id'] as int,
      medicamentId: json['medicament_id'] as int,
      heure: json['heure'] as String,
      joursRepetition: (json['jours_repetition'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      messagePersonnalise: json['message_personnalise'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicament_id': medicamentId,
      'heure': heure,
      'jours_repetition': joursRepetition,
      'message_personnalise': messagePersonnalise,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Créer une copie avec des modifications
  RappelModel copyWith({
    int? id,
    int? medicamentId,
    String? heure,
    List<int>? joursRepetition,
    String? messagePersonnalise,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RappelModel(
      id: id ?? this.id,
      medicamentId: medicamentId ?? this.medicamentId,
      heure: heure ?? this.heure,
      joursRepetition: joursRepetition ?? this.joursRepetition,
      messagePersonnalise: messagePersonnalise ?? this.messagePersonnalise,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Obtenir le texte des jours de répétition
  String getJoursRepetitionText() {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    if (joursRepetition.length == 7) {
      return 'Tous les jours';
    }

    if (joursRepetition.length == 5 &&
        !joursRepetition.contains(6) &&
        !joursRepetition.contains(7)) {
      return 'Jours de semaine';
    }

    if (joursRepetition.length == 2 &&
        joursRepetition.contains(6) &&
        joursRepetition.contains(7)) {
      return 'Weekend';
    }

    final joursActifs = joursRepetition
        .where((jour) => jour >= 1 && jour <= 7)
        .map((jour) => jours[jour - 1])
        .toList();

    return joursActifs.join(', ');
  }

  // Obtenir l'heure formatée
  String getHeureFormatee() {
    final parts = heure.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // Vérifier si le rappel est actif pour aujourd'hui
  bool estActifAujourdHui() {
    if (!isActive) return false;

    final aujourdHui = DateTime.now().weekday; // 1 = Lundi, 7 = Dimanche
    return joursRepetition.contains(aujourdHui);
  }

  @override
  String toString() {
    return 'RappelModel(id: $id, medicamentId: $medicamentId, heure: $heure, jours: $joursRepetition, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RappelModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

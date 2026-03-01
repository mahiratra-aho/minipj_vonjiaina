class MedicamentModel {
  final int id;
  final String nom;
  final String description;
  final String dosage;
  final double prix;
  final int quantite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicamentModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.dosage,
    required this.prix,
    required this.quantite,
    this.createdAt,
    this.updatedAt,
  });

  // Constructeur depuis JSON
  factory MedicamentModel.fromJson(Map<String, dynamic> json) {
    return MedicamentModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String,
      dosage: json['dosage'] as String,
      prix: (json['prix'] as num).toDouble(),
      quantite: json['quantite'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'dosage': dosage,
      'prix': prix,
      'quantite': quantite,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Créer une copie avec des modifications
  MedicamentModel copyWith({
    int? id,
    String? nom,
    String? description,
    String? dosage,
    double? prix,
    int? quantite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicamentModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      prix: prix ?? this.prix,
      quantite: quantite ?? this.quantite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Obtenir le prix formaté
  String getPrixFormate() {
    return '${prix.toStringAsFixed(2)}€';
  }

  // Obtenir la quantité avec unité
  String getQuantiteFormatee() {
    return '${quantite} unités';
  }

  // Vérifier si le médicament est en stock
  bool estEnStock() {
    return quantite > 0;
  }

  @override
  String toString() {
    return 'MedicamentModel(id: $id, nom: $nom, dosage: $dosage, prix: $prix, quantite: $quantite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicamentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

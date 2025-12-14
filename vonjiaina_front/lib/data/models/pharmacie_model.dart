class PharmacieModel {
  final int id;
  final String nom;
  final String? adresse;
  final String? telephone;
  final String type;
  final String statut;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final double? prix;
  final int? quantite;
  final String? nomCommercial;
  final String? prochaineOuverture;
  
  PharmacieModel({
    required this.id,
    required this.nom,
    this.adresse,
    this.telephone,
    required this.type,
    required this.statut,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.prix,
    this.quantite,
    this.nomCommercial,
    this.prochaineOuverture,
  });
  
  bool get isGarde => type == 'garde';
  bool get isOuverte => statut == 'ouverte' || statut == 'garde';
  
  factory PharmacieModel.fromJson(Map<String, dynamic> json) {
    return PharmacieModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      type: json['type'] as String? ?? 'normale',
      statut: json['statut'] as String? ?? 'fermée',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: json['distance_km'] != null 
          ? (json['distance_km'] as num).toDouble() 
          : null,
      prix: json['prix'] != null 
          ? (json['prix'] as num).toDouble() 
          : null,
      quantite: json['quantite'] as int?,
      nomCommercial: json['nom_commercial'] as String?,
      prochaineOuverture: json['prochaine_ouverture'] as String?,
    );
  }
}
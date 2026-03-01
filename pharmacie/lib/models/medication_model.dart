// ── Statut de stock ──────────────────────────────────────────────────────────
enum MedicationStatus { available, lowStock, veryRare, outOfStock }

extension MedicationStatusExt on MedicationStatus {
  String get label {
    switch (this) {
      case MedicationStatus.available:
        return 'DISPONIBLE';
      case MedicationStatus.lowStock:
        return 'PEU EN RÉSERVE';
      case MedicationStatus.veryRare:
        return 'TRÈS RARE';
      case MedicationStatus.outOfStock:
        return 'EN RUPTURE';
    }
  }
}

// ── Catégories — Point 17 ────────────────────────────────────────────────────
enum MedicationCategory {
  analgesicsAntiInflammatory,
  antibioticsAntibacterials,
  antituberculousAntileprosy,
  antimycotics,
  antiviraux,
  cardiologie,
  dermatologie,
  dieteticsNutrition,
  endocrinologie,
  gastroenterologyHepatology,
  gynecologyObstetricsContraception,
  hematologie,
  immunologyAllergology,
  metabolicDisorders,
  neurologie,
  ophthalmology,
  otorhinolaryngology,
  parasitologie,
  pneumologie,
  psychiatrie,
  resuscitationToxicology,
  rheumatology,
  stomatologie,
  urologie,
  vaccinesImunoglobulinsSerotherapy,
  oncology,
  localAnesthetics,
  antiacides,
  calciumAntagonists,
  antiplateletAgents,
  antiarrhythmics,
  anticholinergics,
  antiepileptics,
  circulatingAnticoagulants,
  avkAnticoagulants,
  antidiarrheals,
  h1Antihistamines,
  h2Antihistamines,
  antihypertensives,
  antipsychotics,
  antispasmodics,
  syntheticAntithyroidians,
  anxiolytics,
  betaBlockers,
  cardiotonics,
  diuretics,
  hypnotics,
  injectableHypoglycemics,
  oralHypoglycemics,
  hypolipemiants,
  aceInhibitors,
  angiotensinIiInhibitors,
  mucolytics,
  nootropics,
  phenylethylamines,
  sartans,
  triptans,
  other,
}

extension MedicationCategoryExt on MedicationCategory {
  String get displayName {
    switch (this) {
      case MedicationCategory.analgesicsAntiInflammatory:
        return 'Analgésiques et Anti-inflammatoires';
      case MedicationCategory.antibioticsAntibacterials:
        return 'Antibiotiques et Antibactériens';
      case MedicationCategory.antituberculousAntileprosy:
        return 'Antituberculeux et Antilépreux';
      case MedicationCategory.antimycotics:
        return 'Antimycosiques';
      case MedicationCategory.antiviraux:
        return 'Antiviraux';
      case MedicationCategory.cardiologie:
        return 'Cardiologie';
      case MedicationCategory.dermatologie:
        return 'Dermatologie';
      case MedicationCategory.dieteticsNutrition:
        return 'Diététique et Nutrition';
      case MedicationCategory.endocrinologie:
        return 'Endocrinologie';
      case MedicationCategory.gastroenterologyHepatology:
        return 'Gastro-entérologie et Hépatologie';
      case MedicationCategory.gynecologyObstetricsContraception:
        return 'Gynécologie Obstétrique et Contraception';
      case MedicationCategory.hematologie:
        return 'Hématologie';
      case MedicationCategory.immunologyAllergology:
        return 'Immunologie et Allergologie';
      case MedicationCategory.metabolicDisorders:
        return 'Médicaments des Troubles Métaboliques';
      case MedicationCategory.neurologie:
        return 'Neurologie';
      case MedicationCategory.ophthalmology:
        return 'Ophtalmologie';
      case MedicationCategory.otorhinolaryngology:
        return 'OTO-Rhino-Laryngologie';
      case MedicationCategory.parasitologie:
        return 'Parasitologie';
      case MedicationCategory.pneumologie:
        return 'Pneumologie';
      case MedicationCategory.psychiatrie:
        return 'Psychiatrie';
      case MedicationCategory.resuscitationToxicology:
        return 'Réanimation et Toxicologie';
      case MedicationCategory.rheumatology:
        return 'Rhumatologie';
      case MedicationCategory.stomatologie:
        return 'Stomatologie';
      case MedicationCategory.urologie:
        return 'Urologie';
      case MedicationCategory.vaccinesImunoglobulinsSerotherapy:
        return 'Vaccins, Immunoglobulines, Sérothérapie';
      case MedicationCategory.oncology:
        return 'Cancérologie';
      case MedicationCategory.localAnesthetics:
        return 'Anesthésiques Locaux';
      case MedicationCategory.antiacides:
        return 'Antiacides';
      case MedicationCategory.calciumAntagonists:
        return 'Antagonistes du Calcium';
      case MedicationCategory.antiplateletAgents:
        return 'Antiagrégants Plaquettaires';
      case MedicationCategory.antiarrhythmics:
        return 'Antiarythmiques';
      case MedicationCategory.anticholinergics:
        return 'Anticholinergiques';
      case MedicationCategory.antiepileptics:
        return 'Antiépileptiques';
      case MedicationCategory.circulatingAnticoagulants:
        return 'Anticoagulants Circulants';
      case MedicationCategory.avkAnticoagulants:
        return 'Anticoagulants de Type AVK';
      case MedicationCategory.antidiarrheals:
        return 'Antidiarrhéiques';
      case MedicationCategory.h1Antihistamines:
        return 'Antihistaminiques H1';
      case MedicationCategory.h2Antihistamines:
        return 'Antihistaminiques H2';
      case MedicationCategory.antihypertensives:
        return 'Antihypertenseurs';
      case MedicationCategory.antipsychotics:
        return 'Antipsychotiques';
      case MedicationCategory.antispasmodics:
        return 'Antispasmodiques';
      case MedicationCategory.syntheticAntithyroidians:
        return 'Antithyroïdiens de Synthèse';
      case MedicationCategory.anxiolytics:
        return 'Anxiolytiques';
      case MedicationCategory.betaBlockers:
        return 'Bêta-Bloquants';
      case MedicationCategory.cardiotonics:
        return 'Cardiotoniques';
      case MedicationCategory.diuretics:
        return 'Diurétiques';
      case MedicationCategory.hypnotics:
        return 'Hypnotiques';
      case MedicationCategory.injectableHypoglycemics:
        return 'Hypoglycémiants Injectables';
      case MedicationCategory.oralHypoglycemics:
        return 'Hypoglycémiants Oraux';
      case MedicationCategory.hypolipemiants:
        return 'Hypolipémiants';
      case MedicationCategory.aceInhibitors:
        return 'Inhibiteurs de l\'Enzyme de Conversion';
      case MedicationCategory.angiotensinIiInhibitors:
        return 'Inhibiteurs de l\'Angiotensine II';
      case MedicationCategory.mucolytics:
        return 'Mucolytiques';
      case MedicationCategory.nootropics:
        return 'Nootropiques';
      case MedicationCategory.phenylethylamines:
        return 'Phényléthylamines';
      case MedicationCategory.sartans:
        return 'Sartans (Antagonistes de l\'Angiotensine II)';
      case MedicationCategory.triptans:
        return 'Triptans';
      case MedicationCategory.other:
        return 'Autre';
    }
  }

  String get label => displayName.toUpperCase();

  // Pour correspondance à l'import CSV
  static MedicationCategory fromString(String s) {
    final lower = s.toLowerCase().trim();
    for (final c in MedicationCategory.values) {
      if (c.displayName.toLowerCase() == lower) return c;
    }
    return MedicationCategory
        .other; // fallback to 'other' instead of non-existent 'analgesiques'
  }
}

// ── Modèle médicament ────────────────────────────────────────────────────────
class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final MedicationCategory category;
  final int quantity;
  final int minThreshold;
  final DateTime expiryDate; // seuls mois et année sont utilisés
  final String lotNumber;
  final double? price;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.category,
    required this.quantity,
    required this.minThreshold,
    required this.expiryDate,
    required this.lotNumber,
    this.price,
  });

  // ── Statut stock ───────────────────────────────────────────────────────────
  MedicationStatus get status {
    if (quantity == 0) return MedicationStatus.outOfStock;
    if (quantity <= minThreshold) return MedicationStatus.veryRare;
    if (quantity <= minThreshold * 3) return MedicationStatus.lowStock;
    return MedicationStatus.available;
  }

  bool get isCritical => quantity <= minThreshold;

  double get stockPercentage => (quantity / 100).clamp(0.0, 1.0);

  // ── Point 9 : logique d'expiration ────────────────────────────────────────
  // Bientôt expiré : mois/année d'expiration <= mois/année d'aujourd'hui
  bool get isExpiringSoon {
    final now = DateTime.now();
    final expMonth = DateTime(expiryDate.year, expiryDate.month);
    final nowMonth = DateTime(now.year, now.month);
    return !expMonth.isAfter(nowMonth);
  }

  // Expiré : aujourd'hui est à plus d'1 mois au-delà de la date d'expiration
  bool get isExpired {
    final now = DateTime.now();
    final grace = DateTime(expiryDate.year, expiryDate.month + 1);
    return now.isAfter(grace);
  }

  MedicationModel copyWith({
    String? name,
    String? dosage,
    MedicationCategory? category,
    int? quantity,
    int? minThreshold,
    DateTime? expiryDate,
    String? lotNumber,
    double? price,
  }) {
    return MedicationModel(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minThreshold: minThreshold ?? this.minThreshold,
      expiryDate: expiryDate ?? this.expiryDate,
      lotNumber: lotNumber ?? this.lotNumber,
      price: price ?? this.price,
    );
  }
}

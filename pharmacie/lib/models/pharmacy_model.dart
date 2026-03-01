class OpeningHours {
  final String day;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const OpeningHours({
    required this.day,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  OpeningHours copyWith({String? openTime, String? closeTime, bool? isClosed}) {
    return OpeningHours(
      day: day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

class PharmacyService {
  final String id;
  final String name;
  final String description;
  bool isEnabled;

  PharmacyService({
    required this.id,
    required this.name,
    required this.description,
    this.isEnabled = false,
  });
}

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final String? addressComplement;
  final String email;
  final String phone;
  final String? emergencyPhone;
  final List<OpeningHours> openingHours;
  final List<PharmacyService> services;

  const PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    this.addressComplement,
    required this.email,
    required this.phone,
    this.emergencyPhone,
    required this.openingHours,
    required this.services,
  });

  static PharmacyModel get empty => PharmacyModel(
    id: '',
    name: '',
    address: '',
    email: '',
    phone: '',
    openingHours: defaultHours,
    services: defaultServices,
  );

  // Point 3 : Dimanche ouvert par défaut (pas fermé)
  static List<OpeningHours> get defaultHours => [
    const OpeningHours(day: 'Lundi', openTime: '08:00', closeTime: '19:00'),
    const OpeningHours(day: 'Mardi', openTime: '08:00', closeTime: '19:00'),
    const OpeningHours(day: 'Mercredi', openTime: '08:00', closeTime: '19:00'),
    const OpeningHours(day: 'Jeudi', openTime: '08:00', closeTime: '19:00'),
    const OpeningHours(day: 'Vendredi', openTime: '08:00', closeTime: '19:00'),
    const OpeningHours(day: 'Samedi', openTime: '09:00', closeTime: '18:00'),
    const OpeningHours(day: 'Dimanche', openTime: '09:00', closeTime: '13:00'),
  ];

  // Point 4 : services mis à jour
  static List<PharmacyService> get defaultServices => [
    PharmacyService(
      id: 'delivery',
      name: 'Livraison à domicile',
      description: '',
    ),
    PharmacyService(id: 'parking', name: 'Parking disponible', description: ''),
    PharmacyService(
      id: 'guard_night',
      name: 'Service minimum de garde la nuit',
      description: '',
    ),
    PharmacyService(
      id: 'guard_weekend',
      name: 'Service de garde le weekend',
      description: '',
    ),
  ];
}

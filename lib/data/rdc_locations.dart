// lib/data/rdc_locations.dart
// Structure de données des 26 provinces de la RDC pour DAVIDSTORE.
// available: true  -> province fonctionnelle (villes/communes réelles fournies)
// available: false -> "Bientôt disponible" (aucune ville/commune tant que non activée)

class RdcCity {
  final String name;
  final List<String> communes;

  const RdcCity({
    required this.name,
    this.communes = const [],
  });
}

class RdcProvince {
  final String name;
  final bool available;
  final List<RdcCity> cities;

  const RdcProvince({
    required this.name,
    required this.available,
    this.cities = const [],
  });
}

class RdcLocations {
  static const List<RdcProvince> provinces = [
    RdcProvince(
      name: 'Haut-Katanga',
      available: true,
      cities: [
        RdcCity(
          name: 'Lubumbashi',
          communes: [
            'Katuba',
            'Kampemba',
            'Kenya',
            'Lubumbashi',
            'Ruashi',
            'Annexe',
          ],
        ),
      ],
    ),
    RdcProvince(name: 'Bas-Uélé', available: false),
    RdcProvince(name: 'Équateur', available: false),
    RdcProvince(name: 'Haut-Lomami', available: false),
    RdcProvince(name: 'Haut-Uélé', available: false),
    RdcProvince(name: 'Ituri', available: false),
    RdcProvince(name: 'Kasaï', available: false),
    RdcProvince(name: 'Kasaï-Central', available: false),
    RdcProvince(name: 'Kasaï-Oriental', available: false),
    RdcProvince(name: 'Kinshasa', available: false),
    RdcProvince(name: 'Kongo-Central', available: false),
    RdcProvince(name: 'Kwango', available: false),
    RdcProvince(name: 'Kwilu', available: false),
    RdcProvince(name: 'Lomami', available: false),
    RdcProvince(name: 'Lualaba', available: false),
    RdcProvince(name: 'Mai-Ndombe', available: false),
    RdcProvince(name: 'Maniema', available: false),
    RdcProvince(name: 'Mongala', available: false),
    RdcProvince(name: 'Nord-Kivu', available: false),
    RdcProvince(name: 'Nord-Ubangi', available: false),
    RdcProvince(name: 'Sankuru', available: false),
    RdcProvince(name: 'Sud-Kivu', available: false),
    RdcProvince(name: 'Sud-Ubangi', available: false),
    RdcProvince(name: 'Tanganyika', available: false),
    RdcProvince(name: 'Tshopo', available: false),
    RdcProvince(name: 'Tshuapa', available: false),
  ];
}


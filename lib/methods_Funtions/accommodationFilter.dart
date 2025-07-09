// lib/methods_Funtions/accommodationFilter.dart

import '../classes/listing_model.dart';

class AccommodationFilter {
  static final List<String> provinces = [
    'Gauteng',
    'Western Cape',
    'Eastern Cape',
    'KwaZulu-Natal',
    'Free State',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Northern Cape',
  ];

  static final Map<String, String> universities = {
    'Walter Sisulu University': 'WSU',
    'Cape Peninsula University of Technology': 'CPUT',
    'Central University of Technology': 'CUT',
    'Durban University of Technology': 'DUT',
    'Mangosuthu University of Technology': 'MUT',
    'Nelson Mandela University': 'NMU',
    'North-West University': 'NWU',
    'Rhodes University': 'RU',
    'Sefako Makgatho Health Sciences University': 'SMU',
    'Tshwane University of Technology': 'TUT',
    'University of Cape Town': 'UCT',
    'University of Fort Hare': 'UFH',
    'University of the Free State': 'UFS',
    'University of Johannesburg': 'UJ',
    'University of KwaZulu-Natal': 'UKZN',
    'University of Limpopo': 'UL',
    'University of Mpumalanga': 'UMP',
    'University of Pretoria': 'UP',
    'University of South Africa': 'UNISA',
    'University of Stellenbosch': 'SUN',
    'University of the Western Cape': 'UWC',
    'University of Venda': 'UNIVEN',
    'University of Zululand': 'UNIZULU',
    'University of the Witwatersrand': 'WITS',
    'Vaal University of Technology': 'VUT',
    'Sol Plaatje University': 'SPU',
    'University of Mpumalanga': 'UMP',
    'Sefako Makgatho Health Sciences University': 'SMU',
  };

  static final List<String> knownLocations = [
    'Belhar',
    'Parrow'
        'Cape Town',
    'Bellville',
    'Rosebank',
    'Observatory',
    'Stellenbosch',
    'Cluver Road',
    'Dennesig',
    'Die Boord',

    // Gauteng – Johannesburg & Pretoria
    'Braamfontein',
    'Auckland Park',
    'Parktown',
    'Hatfield',
    'Arcadia',
    'Sunnyside',
    'Centurion',
    'Monument Park',

    // KwaZulu-Natal
    'Glenwood',
    'Westville',
    'Berea',
    'Durban North',

    // Eastern Cape
    'Summerstrand',
    'Central Port Elizabeth',
    'Humewood',

    // Free State
    'Universitas',
    'Brandwag',
    'Willows',
    'Bloemfontein Central',

    // North West
    'Potchefstroom Central',
    'Miederpark',
    'Die Bult',

    // Limpopo
    'Mankweng',
    'Polokwane Central',

    // Mpumalanga
    'Mbombela',
    'Sonheuwel',

    // Northern Cape
    'Kimberley Central',
  ];

  static final RegExp _wordBoundaryRegex = RegExp(r'\b');
  static final RegExp _maleRegex = RegExp(
    r'\b(male|man|boy|males|guys?|gentlemen)\b',
    caseSensitive: false,
  );
  static final RegExp _femaleRegex = RegExp(
    r'\b(female|woman|girls?|females|lad(y|ies))\b',
    caseSensitive: false,
  );
  static final RegExp _mixedRegex = RegExp(
    r'\b(mixed|any|both|all|unisex)\b',
    caseSensitive: false,
  );
  static final RegExp _priceRegex = RegExp(
    r'(?:r\s?)?([\d,]+)(?:\s*(?:rand|rands|p\/m|per\s*month)?)?\b',
    caseSensitive: false,
  );

  static FilterCriteria extractCriteria(String input) {
    final criteria = FilterCriteria();
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains('nsfas')) {
      criteria.isNsfas = true;
    }

    criteria.location = _extractLocation(lowerInput);
    criteria.price = _extractPrice(lowerInput);
    criteria.university = _extractUniversity(lowerInput);

    // Handle implied meanings
    if (lowerInput.contains('cheap') || lowerInput.contains('affordable')) {
      if (criteria.price == 0) {
        criteria.price = 2000; // default ceiling for "cheap"
      }
    }

    return criteria;
  }

  static String _extractLocation(String input) {
    for (var place in [...provinces, ...knownLocations]) {
      if (input.toLowerCase().contains(place.toLowerCase())) {
        return place;
      }
    }
    return '';
  }

  static final RegExp _underPriceRegex = RegExp(r'under\s*r?\s*(\d{3,5})');

  static double _extractPrice(String input) {
    // "under 2500"
    final underMatch = _underPriceRegex.firstMatch(input);
    if (underMatch != null) {
      return double.tryParse(underMatch.group(1) ?? '') ?? 0.0;
    }

    // existing "R2500", "2500 rand"
    final priceMatch = _priceRegex.firstMatch(input);
    if (priceMatch != null) {
      final priceString = priceMatch.group(1)?.replaceAll(',', '');
      return double.tryParse(priceString ?? '') ?? 0.0;
    }

    return 0.0;
  }

  static String _extractUniversity(String input) {
    // Check for full university names
    for (var uniName in universities.keys) {
      if (input.contains(uniName.toLowerCase())) {
        return uniName;
      }
    }
    // Check for abbreviations
    for (var abbreviation in universities.values) {
      if (input.contains(abbreviation.toLowerCase())) {
        // Find the full name corresponding to the abbreviation
        return universities.entries
            .firstWhere(
              (entry) =>
                  entry.value.toLowerCase() == abbreviation.toLowerCase(),
              orElse: () => MapEntry('', ''),
            )
            .key;
      }
    }
    return '';
  }
}

class FilterCriteria {
  // Make fields non-final so they can be assigned after object creation
  bool isNsfas = false;
  String location = '';

  double price = 0.0;
  String university = '';

  // Explicit unnamed constructor (default constructor)
  FilterCriteria();

  bool matches(Listing_model accommodation, {String? currentUserUniversity}) {
    // NSFA filter
    if (isNsfas) {
      if (!accommodation.isNsfas) return false;

      // Extra condition: Only show accommodations that match current user's university
      if (currentUserUniversity != null &&
          currentUserUniversity.isNotEmpty &&
          accommodation.targetInstitution.toLowerCase() != currentUserUniversity.toLowerCase()) {
        return false;
      }
    }

    // Location filter
    if (location.isNotEmpty) {
      final accomLocationLower = accommodation.location.toLowerCase();
      if (!accomLocationLower.contains(location.toLowerCase())) {
        return false;
      }
    }

    // Price filter (match if any room is ≤ the searched price)
    if (price > 0) {
      final singleMatch =
          accommodation.singleRoomPrice > 0 &&
          accommodation.singleRoomPrice <= price;
      final doubleMatch =
          accommodation.doubleRoomPrice > 0 &&
          accommodation.doubleRoomPrice <= price;

      if (!singleMatch && !doubleMatch) {
        return false;
      }
    }

    // University filter
    if (university.isNotEmpty) {
      final uniLower = university.toLowerCase();
      final targetLower = accommodation.targetInstitution.toLowerCase();
      final uniAbbr =
          AccommodationFilter.universities[university]?.toLowerCase() ?? '';

      final nameMatch = targetLower.contains(uniLower);
      final abbrMatch = targetLower == uniAbbr;
      final reverseMatch = uniLower.contains(targetLower);

      if (!nameMatch && !abbrMatch && !reverseMatch) {
        return false;
      }
    }

    return true;
  }

  // Convert FilterCriteria to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'isNsfas': isNsfas,
      'location': location,
      'price': price,
      'university': university,
    };
  }

  // Create FilterCriteria from a Map for deserialization
  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria() // Call the unnamed constructor first
      ..isNsfas = json['isNsfas'] as bool
      ..location = json['location'] as String
      ..price = (json['price'] as num)
          .toDouble() // Ensure correct casting to double
      ..university = json['university'] as String;
  }
}

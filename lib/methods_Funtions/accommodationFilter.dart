// lib/methods_Funtions/accommodationFilter.dart

import '../classes/listing_model.dart';

class AccommodationFilter {
  static final List<String> provinces = [
    'Gauteng', 'Western Cape', 'Eastern Cape', 'KwaZulu-Natal',
    'Free State', 'Limpopo', 'Mpumalanga', 'North West', 'Northern Cape',
  ];

  static final List<String> types = ['house', 'apartment', 'back room'];
  static final List<String> availabilityTypes = ['single', 'double', 'sharing'];

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

  static final RegExp _wordBoundaryRegex = RegExp(r'\b');
  static final RegExp _maleRegex = RegExp(r'\b(male|man|boy|males|guys?|gentlemen)\b', caseSensitive: false);
  static final RegExp _femaleRegex = RegExp(r'\b(female|woman|girls?|females|lad(y|ies))\b', caseSensitive: false);
  static final RegExp _mixedRegex = RegExp(r'\b(mixed|any|both|all|unisex)\b', caseSensitive: false);
  static final RegExp _priceRegex = RegExp(r'(?:r\s?)?([\d,]+)(?:\s*(?:rand|rands|p\/m|per\s*month)?)?\b', caseSensitive: false);

  static FilterCriteria extractCriteria(String input) {
    final criteria = FilterCriteria(); // Use the unnamed constructor

    final lowerInput = input.toLowerCase();

    // Check for "nsfas"
    if (lowerInput.contains('nsfas')) {
      criteria.isNsfas = true;
    }

    // Extract genders
    criteria.genders = _extractGenders(lowerInput);

    // Extract location (province or city)
    criteria.location = _extractLocation(lowerInput);

    // Extract types
    criteria.types = _extractTypes(lowerInput);

    // Extract availability types
    criteria.availabilityTypes = _extractAvailabilityTypes(lowerInput);

    // Extract price
    criteria.price = _extractPrice(lowerInput);

    // Extract university
    criteria.university = _extractUniversity(lowerInput);

    return criteria;
  }

  static List<String> _extractGenders(String input) {
    final genders = <String>[];
    if (_maleRegex.hasMatch(input)) {
      genders.add('male');
    }
    if (_femaleRegex.hasMatch(input)) {
      genders.add('female');
    }
    if (_mixedRegex.hasMatch(input)) {
      genders.add('mixed');
    }
    return genders;
  }

  static String _extractLocation(String input) {
    for (var province in provinces) {
      if (input.contains(province.toLowerCase())) {
        return province;
      }
    }
    // You might want to add logic here to extract city names if needed
    // For now, it only extracts provinces.
    return '';
  }

  static List<String> _extractTypes(String input) {
    final foundTypes = <String>[];
    for (var type in types) {
      if (input.contains(type.toLowerCase())) {
        foundTypes.add(type);
      }
    }
    return foundTypes;
  }

  static List<String> _extractAvailabilityTypes(String input) {
    final foundAvailabilityTypes = <String>[];
    for (var type in availabilityTypes) {
      if (input.contains(type.toLowerCase())) {
        foundAvailabilityTypes.add(type);
      }
    }
    return foundAvailabilityTypes;
  }

  static double _extractPrice(String input) {
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
        return universities.entries.firstWhere(
              (entry) => entry.value.toLowerCase() == abbreviation.toLowerCase(),
          orElse: () => MapEntry('', ''),
        ).key;
      }
    }
    return '';
  }
}

class FilterCriteria {
  // Make fields non-final so they can be assigned after object creation
  bool isNsfas = false;
  List<String> genders = [];
  String location = '';
  List<String> types = [];
  List<String> availabilityTypes = [];
  double price = 0.0;
  String university = '';

  // Explicit unnamed constructor (default constructor)
  FilterCriteria();

  bool matches(Listing_model accommodation) {
    // NSFA filter
    if (isNsfas && !accommodation.isNsfas) {
      return false;
    }

    // Gender filter
    if (genders.isNotEmpty) {
      final accomGenderLower = accommodation.genders.toLowerCase();
      if (!genders.any((g) => accomGenderLower.contains(g.toLowerCase()) || accomGenderLower == 'mixed')) {
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

    // Type filter (e.g., house, apartment)
    if (types.isNotEmpty) {
      final accomTypeLower = accommodation.typeOfAccom.toLowerCase();
      if (!types.any((t) => accomTypeLower.contains(t.toLowerCase()))) {
        return false;
      }
    }

    // Availability type filter (e.g., single, double)
    if (availabilityTypes.isNotEmpty) {
      final accomAvail = accommodation.availableRooms.toLowerCase();
      if (!availabilityTypes.any((a) => accomAvail.contains(a.toLowerCase()))) {
        return false;
      }
    }

    // Price filter (match if any room is ≤ the searched price)
    if (price > 0) {
      final hasSingleRoom = accommodation.singleRoomPrice > 0;
      final hasDoubleRoom = accommodation.doubleRoomPrice > 0;

      final singleMatch = hasSingleRoom && accommodation.singleRoomPrice <= price;
      final doubleMatch = hasDoubleRoom && accommodation.doubleRoomPrice <= price;

      if (!singleMatch && !doubleMatch) {
        return false;
      }
    }


    // University filter (checks full name, abbreviation, and partial matches)
    if (university.isNotEmpty) {
      final uniLower = university.toLowerCase();
      final targetLower = accommodation.targetInstitution.toLowerCase();
      final uniAbbr = AccommodationFilter.universities[university]?.toLowerCase() ?? '';

      // Check if target institution contains university name or abbreviation
      final nameMatch = targetLower.contains(uniLower);
      final abbrMatch = targetLower == uniAbbr;

      // Check if university name contains target institution (for partial matches)
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
      'genders': genders,
      'location': location,
      'types': types,
      'availabilityTypes': availabilityTypes,
      'price': price,
      'university': university,
    };
  }

  // Create FilterCriteria from a Map for deserialization
  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria() // Call the unnamed constructor first
      ..isNsfas = json['isNsfas'] as bool
      ..genders = List<String>.from(json['genders'] as List)
      ..location = json['location'] as String
      ..types = List<String>.from(json['types'] as List)
      ..availabilityTypes = List<String>.from(json['availabilityTypes'] as List)
      ..price = (json['price'] as num).toDouble() // Ensure correct casting to double
      ..university = json['university'] as String;
  }
}



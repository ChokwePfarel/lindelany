
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
    'University of the Witwatersrand': 'WITS',
    'University of Venda': 'UNIVEN',
    'University of Zululand': 'UNIZULU',
    'Vaal University of Technology': 'VUT'
  };

  static FilterCriteria extractCriteria(String input) {
    final criteria = FilterCriteria();
    final normalizedInput = input.toLowerCase().trim();

    if (normalizedInput.isEmpty) return criteria;

    criteria.isNsfas = _containsExactWord(normalizedInput, 'nsfas');
    criteria.genders = _extractGenders(normalizedInput);
    criteria.location = _extractLocation(normalizedInput);
    criteria.types = _extractTypes(normalizedInput);
    criteria.availabilityTypes = _extractAvailabilityTypes(normalizedInput);
    criteria.price = _extractPrice(normalizedInput);
    criteria.university = _extractUniversity(normalizedInput);

    return criteria;
  }

  static bool _containsExactWord(String input, String word) {
    return RegExp(r'\b' + word + r'\b').hasMatch(input);
  }

  static List<String> _extractGenders(String input) {
    final genders = <String>[];

    final maleMatch = RegExp(r'\b(male|man|boy|males|guys?|gentlemen)\b').hasMatch(input);
    final femaleMatch = RegExp(r'\b(female|woman|girl|females|lad(y|ies)|girls)\b').hasMatch(input);
    final mixedMatch = RegExp(r'\b(mixed|any|both|all|unisex)\b').hasMatch(input);

    if (maleMatch && !femaleMatch) genders.add('male');
    if (femaleMatch && !maleMatch) genders.add('female');
    if ((maleMatch && femaleMatch) || mixedMatch) genders.add('mixed');

    return genders;
  }

  static String _extractLocation(String input) {
    // Check provinces first (exact match)
    for (final province in provinces) {
      if (_containsExactWord(input, province.toLowerCase())) {
        return province;
      }
    }

    // Check for city names (more flexible matching)
    final locationWords = input.split(RegExp(r'[\s,]+'))
        .where((word) => word.length >= 3)
        .where((word) => !_isCommonWord(word))
        .where((word) => !types.contains(word))
        .where((word) => !availabilityTypes.contains(word))
        .where((word) => !universities.keys.any((uni) => uni.toLowerCase().contains(word)))
        .where((word) => !universities.values.any((abbr) => abbr.toLowerCase() == word));

    return locationWords.isNotEmpty ? locationWords.first : '';
  }

  static bool _isCommonWord(String word) {
    const commonWords = [
      'for', 'and', 'the', 'near', 'in', 'at', 'to', 'with', 'by',
      'accommodation', 'rooms','place', 'room', 'rent', 'looking', 'under',
      'nsfas', 'male', 'female', 'mixed', 'single', 'double', 'sharing',
      'price', 'accredited', 'cost', 'around', 'about','in' 'approximately', 'close', 'to'
    ];
    return commonWords.contains(word);
  }

  static List<String> _extractTypes(String input) {
    return types.where((type) => _containsExactWord(input, type)).toList();
  }

  static List<String> _extractAvailabilityTypes(String input) {
    return availabilityTypes.where((type) => _containsExactWord(input, type)).toList();
  }

  static double _extractPrice(String input) {
    // Match prices like R3000, 3000, R3,000, R 3000, 3000 p/m, 4000 rand, etc.
    final priceMatch = RegExp(
      r'(?:r\s?)?([\d,]+)(?:\s*(?:rand|rands|p\/m|per\s*month)?)?\b',
      caseSensitive: false,
    ).firstMatch(input);

    if (priceMatch == null) return 0.0;

    final priceString = priceMatch.group(1)!.replaceAll(',', '');
    return double.tryParse(priceString) ?? 0.0;
  }



  static String _extractUniversity(String input) {
    // 1. Check for exact university name matches
    for (final uni in universities.keys) {
      if (_containsExactWord(input, uni.toLowerCase())) {
        return uni;
      }
    }

    // 2. Check for abbreviations (UCT, UP, etc.)
    for (final entry in universities.entries) {
      if (_containsExactWord(input, entry.value.toLowerCase())) {
        return entry.key;
      }
    }

    // 3. Check for partial matches (e.g., "cape town" matches "University of Cape Town")
    for (final uni in universities.keys) {
      final uniParts = uni.toLowerCase().split(' ');
      if (uniParts.any((part) => part.length > 3 && _containsExactWord(input, part))) {
        return uni;
      }
    }

    // 4. Check for common nicknames (e.g., "wits" for "University of the Witwatersrand")
    final nicknameMatches = {
      'wits': 'University of the Witwatersrand',
      'tuks': 'University of Pretoria',
      'maties': 'University of Stellenbosch',
    };

    for (final entry in nicknameMatches.entries) {
      if (_containsExactWord(input, entry.key)) {
        return entry.value;
      }
    }

    return '';
  }
}

class FilterCriteria {
  bool isNsfas = false;
  List<String> genders = [];
  String location = '';
  List<String> types = [];
  List<String> availabilityTypes = [];
  double price = 0.0;
  String university = '';

  bool matches(Listing_model accommodation) {
    // NSFW filter
    if (isNsfas && !accommodation.isNsfas) return false;

    // Gender filter
    if (genders.isNotEmpty) {
      final accomGender = accommodation.genders.toLowerCase();
      if (!genders.any((g) => accomGender == g.toLowerCase())) {
        return false;
      }
    }

    // Location filter (checks both location and province fields)
    if (location.isNotEmpty) {
      final locLower = location.toLowerCase();
      final accomLocLower = accommodation.location.toLowerCase();
      final accomProvLower = accommodation.provinces.toLowerCase();

      if (!accomLocLower.contains(locLower) &&
          !accomProvLower.contains(locLower)) {
        return false;
      }
    }

    // Accommodation type filter
    if (types.isNotEmpty) {
      final accomType = accommodation.typeOfAccom.toLowerCase();
      if (!types.any((t) => accomType.contains(t.toLowerCase()))) {
        return false;
      }
    }

    // Room availability type filter
    if (availabilityTypes.isNotEmpty) {
      final accomAvail = accommodation.availableRooms.toLowerCase();
      if (!availabilityTypes.any((a) => accomAvail.contains(a.toLowerCase()))) {
        return false;
      }
    }

    // Price filter (with ±10% range)
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
}





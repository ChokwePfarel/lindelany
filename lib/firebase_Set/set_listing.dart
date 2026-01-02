import 'package:cloud_firestore/cloud_firestore.dart';
import '../Constants/lists.dart';
import '../classes/listing_model.dart';

class Listing {
  final CollectionReference reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );

  Future<String> createListing(
    String userId,
    String accommodationName,
    String location,
    String targetInstitution,
    bool isNsfas,
    bool isWifi,
    bool isParking,
    String phoneNumbers,
    String aboutAccom,
    int doubleRoomPrice,
    int singleRoomPrice,
    bool isFull,
    String selectedProvince,
    String selectedGenders,
    String selectedType,
    String availableRooms,
    String aboutPayment,
    bool laundry,
    bool tv,
    bool security,
    bool transport,
    bool kitchen,
    bool bed,
    bool shower,
    List<String> imageUrls,
    String pictureUrl,
    String plan,
    int amount,
    String paymentId,
    Timestamp createdAt,
    Timestamp paymentExpiryDate,
    bool isTexted,
    String status,

    bool isWalkable,
    bool isVerified,

    String address,
    String city,
    String postalCode,

      String verificationStatus,
  ) async {
    try {
      DocumentReference docRef = await reference.add({
        'userId': userId,
        'accommodationName': accommodationName,
        'location': location,
        'targetInstitution': targetInstitution,
        'aboutAccom': aboutAccom,
        'phoneNumbers': phoneNumbers,
        'isNsfas': isNsfas,
        'isWIFI': isWifi,
        'isParking': isParking,
        'doubleRoomPrice': doubleRoomPrice,
        'singleRoomPrice': singleRoomPrice,
        'isFull': isFull,
        'provinces': selectedProvince,
        'genders': selectedGenders,
        'typeOfAccom': selectedType,
        'availableRooms': availableRooms,
        'imageUrls': imageUrls,
        'aboutPayment': aboutPayment,
        'laundry': laundry,
        'tv': tv,
        'security': security,
        'transport': transport,
        'kitchen': kitchen,
        'bed': bed,
        'shower': shower,
        'pictureUrl': pictureUrl,
        'plan': plan,
        'amount': amount,
        'paymentId': paymentId,
        'createdAt': createdAt,
        'paymentExpiryDate': paymentExpiryDate,
        'isTexted': isTexted,
        'status': status,
        'isWalkable': isWalkable,
        'isVerified': isVerified,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'verificationStatus':verificationStatus,
      });
      await docRef.update({'accommodationId': docRef.id});

      return docRef.id;
    } catch (e) {
      return '';
    }
  }

  //-----------------------------Get specific listing---------------------------

  Stream<Listing_model> currentUserListing(String documentId) {
    return reference.doc(documentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return Listing_model(
          userId: '',
          accommodationId: '',
          accommodationName: '',
          location: '',
          targetInstitution: southAfricanUniversities.first,
          isNsfas: false,
          isWifi: false,
          isParking: false,
          phoneNumbers: '',
          aboutAccom: '',
          isFull: false,
          singleRoomPrice: 0,
          doubleRoomPrice: 0,
          provinces: '',
          genders: '',
          typeOfAccom: '',
          availableRooms: '',
          aboutPayment: '',
          laundry: false,
          tv: false,
          security: false,
          transport: false,
          kitchen: false,
          bed: false,
          shower: false,
          imageUrls: [],
          pictureUrl: '',
          plan: '',
          amount: 0,
          paymentId: '',
          createdAt: Timestamp(0, 0).toDate(),
          paymentExpiryDate: Timestamp(0, 0).toDate(),
          isTexted: false,
          hasPaid: false,
          status: '',
          isWalkable: false,
          address: '',
          city: '',
          postalCode: '',
          isVerified: false,
          verificationStatus: '',
          verificationRequestId: '',
          verifiedAt: null,
          verifiedBy: '',
          verificationDocs: [],
          landlordIdNumber: '',
        );
      }
      return Listing_model.fromDocument(doc);
    });
  }

  //------------------------------Lazy Loading----------------------------------

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  Future<List<Listing_model>> fetchListings({
    int limit = 10,
    String? searchText,
    String? selectedUniversity,
  }) async {
    if (!_hasMore) return [];

    Query query = reference
        .where('paymentExpiryDate', isGreaterThan: Timestamp.now())
        .where('isFull', isEqualTo: false);

    if (searchText != null && searchText.trim().isNotEmpty) {
      final searchLower = searchText.trim().toLowerCase();

      if (searchLower == 'nsfas') {
        query = query
            .where('isNsfas', isEqualTo: true)
            .where('targetInstitution', isEqualTo: selectedUniversity);
      }
      // Price search
      else if (double.tryParse(searchLower) != null) {
        final price = double.parse(searchLower);
        query = query
            .where('singleRoomPrice', isLessThanOrEqualTo: price)
            .where('targetInstitution', isEqualTo: selectedUniversity);
      }
      // University search (exact match)
      else if (searchLower.contains('university')) {
        query = query.where('targetInstitution', isEqualTo: searchText);
      }
      // Location search (exact match)
      else {
        query = query.where('location', isEqualTo: searchText);
      }
    } else {
      // No search text, optionally filter by selected university
      if (selectedUniversity != null && selectedUniversity.isNotEmpty) {
        query = query.where('targetInstitution', isEqualTo: selectedUniversity);
      }
    }
    // Order for pagination
    query = query
        .orderBy('paymentExpiryDate', descending: true)
        .limit(limit + 1); // fetch one extra to check hasMore

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }

    if (snapshot.docs.length > limit) {
      _hasMore = true;
      _lastDoc = snapshot.docs[limit - 1];
      return snapshot.docs
          .take(limit)
          .map((doc) => Listing_model.fromDocument(doc))
          .toList();
    } else {
      _hasMore = false;
      _lastDoc = snapshot.docs.last;
      return snapshot.docs
          .map((doc) => Listing_model.fromDocument(doc))
          .toList();
    }
  }

  void resetPagination() {
    _lastDoc = null;
    _hasMore = true;
  }

  bool get hasMore => _hasMore;

  //-------------------------Create Dummy accommodation-------------------------
}

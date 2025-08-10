import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Constants/Lists.dart';
import '../classes/listing_model.dart';

class Listing {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );

  // Function to save user profile info
  Future<void> createListing(
    String userId,
    String accommodationName,
    String location,
    String targetInstitution,
    bool isNsfas,
    bool isWifi,
    bool isParking,
    String phoneNumbers,
    String aboutAccom,
    double doubleRoomPrice,
    double singleRoomPrice,
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
    double amount,
    String paymentId,
    Timestamp createdAt,
    Timestamp paymentExpiryDate,
    //bool hasFreeTrial,
    bool isTexted,
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
        //'hasFreeTrial': hasFreeTrial,
        'isTexted': isTexted,
      });

      //Set the accommodationId to thee id if the document when done creating one
      await docRef.update({'accommodationId': docRef.id});
    } catch (e) {
      print('Error saving profile info: ${e.toString()}');
    }
  }

  Stream<Listing_model> CurrentUserListing(documentId) {
    return reference.doc(documentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Fall back, accommodate');
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
          amount: 0.0,
          paymentId: '',
          createdAt: Timestamp(0, 0).toDate(),
          paymentExpiryDate: Timestamp(0, 0).toDate(),
          isTexted: false,
          hasPaid: false,
          //hasFreeTrial: true,
        );
      }

      print('Current user listing');
      return Listing_model.fromDocument(doc);
    });
  }

  // Helper method to convert Firestore snapshot to list of AppUserModel
  List<Listing_model> dataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Using fall back: List accommodation');
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
          singleRoomPrice: 0.0,
          doubleRoomPrice: 0.0,
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
          amount: 0.0,
          paymentId: '',
          createdAt: Timestamp(0, 0).toDate(),
          paymentExpiryDate: Timestamp(0, 0).toDate(),
          isTexted: false,
          hasPaid: false,
          // hasFreeTrial: false,
        );
      }

      return Listing_model.fromDocument(doc);
    }).toList();
  }

  //Getting all documents in Accommodation collextion
/*  Stream<List<Listing_model>> get allAccommodations {
    return reference.where('isFull', isEqualTo: false).snapshots().map((doc) {
      print('Received accommodation snapshot: ${doc.docs.length} documents');
      return dataFromSnapshot(doc);
    });
  }*/

  //Helps prevent showing all docs for a texted user
  Stream<List<Listing_model>> get ListingWhereTrue {
    return reference.where('isTexted', isEqualTo: true).snapshots().map((doc) {
      print('Received accommodation snapshot: ${doc.docs.length} documents');
      return dataFromSnapshot(doc);
    });
  }

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  Future<List<Listing_model>> fetchListings({int limit = 10}) async {
    if (!_hasMore) return [];

    // Always use a stable order for pagination
    Query query = reference
        .where('paymentExpiryDate', isGreaterThan: Timestamp.now())
        .where('isFull', isEqualTo: false)
        .orderBy('paymentExpiryDate', descending: true)
        .limit(limit + 1); // request one extra doc

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }

    // If we got more than the limit, it means there’s another page
    if (snapshot.docs.length > limit) {
      _hasMore = true;
      // Save the extra doc for the next page
      _lastDoc = snapshot.docs[limit - 1];
      // Only return the first `limit` docs to the UI
      return snapshot.docs
          .take(limit)
          .map((doc) => Listing_model.fromDocument(doc))
          .toList();
    } else {
      // No more pages
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
}

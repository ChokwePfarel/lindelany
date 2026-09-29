import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Constants/lists.dart';
import '../models/listing_model.dart';

class AccomStream {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );

  List<Listing_model> dataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
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
    }).toList();
  }

  Stream<List<Listing_model>> userAccommodations(String landlordId) {
    return _reference
        .where('userId', isEqualTo: landlordId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return dataFromSnapshot(snapshot);
    });
  }

}

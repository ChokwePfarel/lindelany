import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Constants/Lists.dart';
import '../classes/listing_model.dart';

///Get current user accommodations
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
        );
      }

      return Listing_model.fromDocument(doc);
    }).toList();
  }

  Stream<List<Listing_model>> get userAccommodations {
    return _reference
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          for (var doc in snapshot.docs) {
            //         print('listing id :${doc.id}, UID : ${doc['userId']}');
          }
          //       print('Doc for stu: ${snapshot.docs.length} documents');

          return dataFromSnapshot(snapshot);
        });
  }
}

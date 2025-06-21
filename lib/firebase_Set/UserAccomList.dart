import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../classes/listing_model.dart';
import 'houseListing.dart';


///Get current user accommodations
class accomStream {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('Accommodation');

  Stream<List<Listing_model>> get userAccommodations{
    return _reference.where('userId', isEqualTo: _auth.currentUser!.uid).snapshots().map((snapshot) {

      for(var doc in snapshot.docs){
        print('Doc Id :${doc.id}, UID : ${doc['userId']}');
      }
      print('Doc for stu: ${snapshot.docs.length} documents');

      return Listing().dataFromSnapshot(snapshot);
    });
  }
}

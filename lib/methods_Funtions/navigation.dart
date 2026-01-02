import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomNavigation {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _reference = FirebaseFirestore.instance;


  //CHECK IS A DOCUMENT EXISTS
  Future<bool> getDocumentBool(String collection) async {
    String userId = _auth.currentUser!.uid;

    try {
      DocumentSnapshot doc = await _reference.collection(collection)
          .doc(userId)
          .get();

      bool existance = doc.exists;

////       print('Documents found $existance');

      return existance;
    } catch (e) {
////       print('Error while checking for document $e');
    }
    return false;
  }
}

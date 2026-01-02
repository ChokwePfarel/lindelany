import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationService {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'awaitVerification',
  );

  //----------------------------------------------------------------------------
  Future<void> updateRequest(String requestId, String imageUrl) async {
    await _reference.doc(requestId).update({'proofImage': imageUrl});
  }


  //------------------------------------------------------------------------------


  Future<String> createDocument(String accomId, String userId, String email,
      String accomName, String address, String city, String code) async {
    try {
      DocumentReference docRef = await _reference.add({
        'accommodationId': accomId,
        'userId': userId,
        'userEmail': email,
        'accommodationName': accomName,
        'address': address,
        'city': city,
        'postalCode': code,
        'submittedAt': FieldValue.serverTimestamp(),
        'proofImage': '', // Placeholder
      });

      return docRef.id;

    } catch (e) {
      //
      print('FAILED TO CREATE A REQUEST ${e.toString()}');

      return '';
    }
  }

}





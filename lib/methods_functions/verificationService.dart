import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VerificationService {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'awaitVerification',
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> submitVerification({
    required String accommodationId,
    required String accommodationName,
    required String address,
    required String city,
    required String postalCode,
    required String userId,
    required File proofImage,
  }) async {
    final requestRef =
    _firestore.collection('awaitVerification').doc();

    // Create request
    await requestRef.set({
      'accommodationId': accommodationId,
      'userId': userId,
      'userEmail': _auth.currentUser?.email ?? '',
      'accommodationName': accommodationName,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'submittedAt': FieldValue.serverTimestamp(),
      'proofImage': '',
    });

    // Update listing status
    await _firestore
        .collection('Accommodation')
        .doc(accommodationId)
        .update({'verificationStatus': 'waiting'});

    // Upload image
    final imageUrl = await _uploadProofImage(userId, proofImage);

    // Update request with image
    await requestRef.update({'proofImage': imageUrl});
  }

  Future<String> _uploadProofImage(String userId, File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('proofs/${userId}_proof.jpg');

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

}





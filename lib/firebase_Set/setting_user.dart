import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingUser {
  final CollectionReference  _reference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///Setting a user
  Future <void> userDetails(String userId, String UserName,
      String userType, String userGender,
      String profilePictureUrl,bool hasPaid,
      List<dynamic> paymentHistory,Timestamp latestMessageTimestamp)
  async {
    try{
      final userId = _auth.currentUser!.uid;

      await _reference.doc(userId).set({
        'userId' : userId,
        'UserName': UserName,
        'userType': userType,
        'userGender': userGender,
        'profilePictureUrl': profilePictureUrl,
        'hasPaid' : hasPaid,
        'paymentHistory' : paymentHistory,
        'latestMessageTimestamp': latestMessageTimestamp
      });

    } catch (e){print(e.toString());}
  }
}

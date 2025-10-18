import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_Set/user.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isSignedOut = false;
  bool get isSignedOut => _isSignedOut;

  Future<void> saveFcmToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fcmToken': token,
      });
//       print('FCM token saved successfully. Token: $token');
    }
  }



  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if(result.user != null){
        await saveFcmToken(result.user!.uid);
      }

      return result.user;


    } catch (e) {
      // Handle error
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password,String UserName,String userType,String userGender) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if(user != null){
        UserProvider(uid: user.uid).createUser(
            UserName,
            userType,
            userGender,
            '',
            true);

        await saveFcmToken(user.uid);
      }
      return result.user;

    } catch (e) {
//       print('Failed to create a user: $e');
      return null;
    }
  }

//------------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _isSignedOut = true;
//       print("User signed out successfully");
    } catch (e) {
//       print("Sign out failed: $e");
    }
  }

//------------------------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle error
    }
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_Set/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSignedOut = false;

  bool get isSignedOut => _isSignedOut;

  Future<void> saveFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final userId = _auth.currentUser!.uid ?? '';
    if (token != null) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fcmToken': token,
        'dateCreated': Timestamp.now(),
      });

      print('TOKEN UPDATED');
    }
  }

//------------------------------------------------------------------------------
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await saveFcmToken();
      }

      return result.user;
    } catch (e) {
      return null;
    }
  }

//------------------------------------------------------------------------------
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String UserName,
    String userType,
    String userGender,
  ) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = result.user;

      if (user != null) {
        UserProvider().createUser(
          user.uid,
          UserName,
          userType,
          userGender,
          '',
          true,
        );

        await saveFcmToken();
      }
      return result.user;
    } catch (e) {
      return null;
    }
  }

  //----------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _isSignedOut = true;

    } catch (e) {
      //
    }
  }

  //----------------------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'invalid-email') {
      } else {}
    } catch (e) {
      // Handle
    }
  }
}

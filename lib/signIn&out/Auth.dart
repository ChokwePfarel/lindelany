import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_Set/user.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isSignedOut = false;
  bool get isSignedOut => _isSignedOut;


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
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
        UserProvider(uid: user.uid).createUser(UserName, userType, userGender, '', true);
        //UserProvider().createUser(user.uid, UserName, userType, userGender, '',false,[]);
      }

      return result.user;
      
      
    } catch (e) {
      // Handle error
      return null;
    }
  }




//------------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _isSignedOut = true;
      print("User signed out successfully");
    } catch (e) {
      print("Sign out failed: $e");
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



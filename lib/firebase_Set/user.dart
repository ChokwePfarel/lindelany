import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../classes/user_model.dart';

class UserProvider extends ChangeNotifier {
  final String? uid;

  UserProvider({this.uid});

  UserModel? _user;

  UserModel? get user => _user;

  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Users',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creating a new user
  Future<void> createUser(
    String userName,
    String userType,
    String userGender,
    String profilePictureUrl,
    bool isFreeTrial,
  ) async {
    try {
      await _reference.doc(uid).set({
        'userId': uid,
        'userName': userName.trim(),
        'userType': userType,
        'userGender': userGender,
        'profilePictureUrl': profilePictureUrl,
        'isFreeTrial': isFreeTrial,
      });
    } catch (e) {
      //       print('Error creating user: $e');
    }
  }

  Future<void> fetchUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    String userId = auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      //       print('No user is currently signed in');
      return;
    }

    DocumentSnapshot<Object?>? doc;
    try {
      doc = await _reference
          .doc(userId)
          .get(const GetOptions(source: Source.cache));

      //       print('found data in cache');

      if (!doc.exists || doc.data() == null) {
        doc = await _reference
            .doc(userId)
            .get(const GetOptions(source: Source.server));
        //         print('found data in server');
        //         print('current userId: $userId');
      }
    } catch (e) {
      //       print(userId);
      debugPrint('Error fetching user data: $e');
    }

    // Only assign _user if doc is valid
    if (doc == null || !doc.exists || doc.data() == null) {
      //       print('user fallback');
      _user = UserModel(
        userId: '',
        userName: '',
        userType: '',
        userGender: '',
        profilePictureUrl: '',
        isFreeTrial: false,
      );
    } else {
      //       print("User doc");
      _user = UserModel.fromDocument(doc);
    }
    notifyListeners();
  }

  /*Future currentUserName() async {
    await fetchUser();
    return _user!.userName;
  }*/

  Stream<UserModel> currentUserData() {
    String userId = _auth.currentUser?.uid ?? '';

    return _reference.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        //         print('Using fall back: A UserModel');

        final fallBack = UserModel(
          userId: '',
          userName: '',
          userType: '',
          userGender: '',
          profilePictureUrl: '',
          isFreeTrial: true,
        );
        return fallBack;
      }
      return UserModel.fromDocument(doc);
    });
  }

  List<UserModel> _helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        //         print('Using fall back: List UserModel');
        return UserModel(
          userId: '',
          userName: '',
          userType: '',
          userGender: '',
          profilePictureUrl: '',
          isFreeTrial: true,
        );
      }
      return UserModel.fromDocument(doc);
    }).toList();
  }

  ///Gets all the users
  Stream<List<UserModel>> get allUsers {
    return _reference.snapshots().map((snapshot) {
      //       print('Received user snapshot: ${snapshot.docs.length} documents');
      return _helper(snapshot);
    });
  }

  //Problems displaying user info immediately after signing up
  /*
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }*/


//-----------------------------------Fetch all users----------------------------

}

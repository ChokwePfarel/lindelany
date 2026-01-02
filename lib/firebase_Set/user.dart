import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../classes/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool isUserLoading = true;

  UserModel? get user => _user;

  final CollectionReference _reference =
  FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //---------------------------------------------------------Creating a new user
  Future<void> createUser(
    String uid,
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
      //      //       print('Error creating user: $e');
    }
  }

  //---------------------------------------------------------fetc use-----------

  Future<UserModel?> fetchUser({
    Source source = Source.serverAndCache,
  }) async {
    String userId = _auth.currentUser?.uid ?? '';

    isUserLoading = true;
    notifyListeners();

    if (userId.isEmpty) {
      _user = null;
      isUserLoading = false;
      notifyListeners();
      return null;
    }

    DocumentSnapshot<Object?>? doc;
    final GetOptions options = GetOptions(source: source);

    try {
      doc = await _reference.doc(userId).get(options);

      // If cache-only returned nothing → fallback to server
      if (source == Source.cache && (!doc.exists || doc.data() == null)) {
        doc = await _reference
            .doc(userId)
            .get(const GetOptions(source: Source.server));
      }

      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromDocument(doc);
      } else {
        _user = null;
      }
    } catch (e) {
      _user = null;
    }

    isUserLoading = false;
    notifyListeners();

    return _user;
  }

  // Clear data on logout
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Stream<UserModel> currentUserData() {
    String userId = _auth.currentUser?.uid ?? '';

    return _reference.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
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

  List<UserModel> helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
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

  //Listen to the entire collection
  Stream<List<UserModel>> get allUsers {
    return _reference.snapshots().map((snapshot) {
      return helper(snapshot);
    });
  }

  //-----------------------------------Fetch all users--------------------------

  Future fetchAllUsers() async {
    final userSnapshot = await _reference.get();
  }
}

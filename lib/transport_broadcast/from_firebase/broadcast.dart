import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../broadcast_vehicle_model.dart';



class broadcast {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference =
  FirebaseFirestore.instance.collection('broadcasts');

  //----------------------------------------------------------------------create
  Future<DocumentReference?> createBroadcast(
      String Uid,
      String senderName,
      String message,
      List<String> images,
      String status,
      String university,
      bool isCompleted,
      Timestamp createdAt) async {
    try {
      DocumentReference doccumentt = await _reference.add({
        'userId': Uid,
        'userName': senderName,
        'message': message,
        'imageUrls': images,
        'institution': university,
        'createdAt': createdAt,
        'completed': isCompleted,
      });

      await doccumentt.update({'postId': doccumentt.id});

      return doccumentt; //ILL PASS THIS DIRECTLY
    } catch (e) {
      print('Error creating broadcast ${e.toString()}');

      return null;
    }
  }

  //------------------------------------------------------currentUser broadcasts

  Stream<BroadcastModel> userBroadcasts(documentId) {
    return _reference.doc(documentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Using fallback for currentUser broadcasts');
        return BroadcastModel(
            userId: 'noUserId',
            postId: 'noDocId',
            senderName: '',
            broadcast: '',
            images: [],
            uni: '',
            createdAt: Timestamp(0, 0),
            completed: false);
      }

      var data = doc.data() as Map<String, dynamic>;
      return BroadcastModel.fromDocument(doc);
    });
  }

//----------------------------------------------------------------All broadcasts

  List<BroadcastModel> _helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Using fallback for lists of broadcasts');
        return BroadcastModel(
            userId: '',
            postId: '',
            senderName: '',
            broadcast: '',
            images: [],
            uni: '',
            createdAt: Timestamp(0, 0),
            completed: false);
      }

      var data = doc.data() as Map<String, dynamic>;

      return BroadcastModel.fromDocument(doc);
    }).toList();
  }

//------------------------------------------------------------------------Stream

  Stream<List<BroadcastModel>> get listOfBroadcast {
    return _reference
        .where('completed', isEqualTo: false)
        .snapshots()
        .map((docs) {
      print('Received broadcasts snapshots : ${docs.docs.length}');
      return _helper(docs);
    });
  }
   //---------------------------------------------------------------------------
  //pagination
  //----------------------------------------------------------------------------
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  /// Fetches broadcasts with pagination
  /// Set [reset] = true for pull-to-refresh (resets pagination)
  Future<List<BroadcastModel>> fetchBroadcasts({
    int limit = 10,
    bool reset = false,
  }) async {
    if (reset) {
      _lastDoc = null;
      _hasMore = true;
    }

    if (!_hasMore) return [];

    Query query = _reference
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true) // ensure consistent ordering
        .limit(limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
    } else {
      _hasMore = false;
    }

    print('Received broadcasts snapshot: ${snapshot.docs.length} documents');
    return snapshot.docs
        .map((doc) => BroadcastModel.fromDocument(doc))
        .toList();
  }

  void resetPagination() {
    _lastDoc = null;
    _hasMore = true;
  }

  bool get hasMore => _hasMore;

//-------------------------------------------------------------a users broadcast

  Stream<List<BroadcastModel>> get userBroadcast {
    return _reference
        .where('userId', isEqualTo: _auth.currentUser!.uid).
    orderBy('createdAt', descending: true).
        snapshots()
        .map((snapshot) {
      print('Current user broadcast: ${snapshot.docs.length} documents');

      return _helper(snapshot);
    });
  }
}

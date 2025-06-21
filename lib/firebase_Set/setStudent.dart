import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../classes/student_model.dart';

class StudentProvider extends ChangeNotifier {
  StudentModel? _currentStudent;
  StudentModel? get currentUser => _currentStudent;

  final CollectionReference _reference = FirebaseFirestore.instance.collection('StudentForm');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StudentProvider() {
    currentStudent(); // Automatically fetches when the provider is created
  }

  // Fetch current student info with Hive caching
  Future<void> currentStudent() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    //final box = Hive.box<StudentModel>('student');

    // Step 1: Load from Hive (if available)
   // final cached = box.get(userId);
    /*if (cached != null ) {
      _currentStudent = cached;
      notifyListeners(); // notify with cached data immediately
    }*/

    // Step 2: Load from Firestore (cache first, fallback to server)
    DocumentSnapshot<Object?>? doc;
    try {
      doc = await _reference.doc(userId).get(const GetOptions(source: Source.cache));
      if (!doc.exists || doc.data() == null) {
        doc = await _reference.doc(userId).get(const GetOptions(source: Source.server));
      }
    } catch (e) {
      print('Error accessing Firestore: $e');
    }

    //Doc exist in cache or server, if not, fall back
    if (doc == null || !doc.exists || doc.data() == null) {
      print('Using fallback: a student');
      _currentStudent = StudentModel(
        userId: 'current student id',
        province: '',
        uni: 'University',
        year: '1st',
        payment: 'Payment',
      );
    } else {
      final rawData = doc.data();
      if (rawData is Map<String, dynamic>) {
        _currentStudent = StudentModel.fromDocument(doc);

        // Step 3: Update Hive with fresh data
        //await box.put(userId, _currentStudent!); // for ID-based access (e.g., for messages).
        //await box.put('currentStudent', _currentStudent!.copy()); //for profile/dashboard screens.

      }
    }

    notifyListeners();
  }

  // Stream of current student, updates Hive when new data arrives
  Stream<StudentModel> currentStudentDoc() {
    String userId = _auth.currentUser!.uid;

    return _reference.doc(userId).snapshots().map((doc) {

      if (!doc.exists || doc.data() == null) {
        final fallback = StudentModel(
          userId: 'current student id',
          province: '',
          uni: 'University',
          year: '1st',
          payment: 'Payment',
        );
        return fallback;
      }

      final updated = StudentModel.fromDocument(doc);

      return updated;
    });
  }

  // Helper for mapping Firestore snapshots to studentModel list
  List<StudentModel> _helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        return StudentModel(
          userId: 'userId',
          province: 'update pro',
          uni: 'Update uni',
          year: 'Update year',
          payment: 'Update payment',
        );
      }

      return StudentModel.fromDocument(doc);
    }).toList();
  }

  // Stream of all students
  Stream<List<StudentModel>> get studentsStream {
    return _reference.snapshots().map((doc) {

      print('Received student snapshot: ${doc.docs.length} documents');
      return _helper(doc);
    });
  }
}


/*class student extends ChangeNotifier {
  studentModel? _currentStudent;

  studentModel? get currentUser => _currentStudent;

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('StudentForm');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current student info
  Future<void> currentStudent() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    DocumentSnapshot<Object?>? doc;

    try {
      // Try local cache first
      doc = await _reference
          .doc(userId)
          .get(const GetOptions(source: Source.cache));

      // Fallback to server if not found in cache
      if (!doc.exists || doc.data() == null) {
        doc = await _reference
            .doc(userId)
            .get(const GetOptions(source: Source.server));
      }
    } catch (e) {
      print('Error accessing Firestore: $e');
    }

    if (doc == null || !doc.exists || doc.data() == null) {
      print('Using fallback: a student');
      _currentStudent = studentModel(
        userId: 'current student id',
        province: '',
        uni: 'University',
        year: '1st',
        payment: 'Payment',
      );
    } else {
      final rawData = doc.data();
      if (rawData is Map<String, dynamic>) {
        final data = rawData;
        _currentStudent = studentModel(
          userId: data['userId'] ?? userId,
          province: data['Province'] ?? '',
          uni: data['Uni'] ?? '',
          year: data['Year'] ?? '',
          payment: data['Payment'] ?? '',
        );
      }
    }

    notifyListeners();
  }

  Stream<studentModel> currentStudentDoc() {
    String Uid = _auth.currentUser!.uid ?? '';
    return _reference.doc(Uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Using fall back: a student');
        return studentModel(
            userId: 'current student id',
            province: '',
            uni: 'University',
            year: '1st',
            payment: 'Payment');
      }

      var data = doc.data() as Map<String, dynamic>;
      return studentModel(
          userId: data['userId'],
          province: data['Province'] ?? '',
          uni: data['Uni'] ?? '',
          year: data['Year'] ?? '',
          payment: data['Payment'] ?? '');
    });
  }

  //SnapShot convertor

  List<studentModel> _helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        return studentModel(
            userId: 'userId',
            province: 'update pro',
            uni: 'Update uni',
            year: 'Update year',
            payment: 'Update payment');
      }
      var data = doc.data() as Map<String, dynamic>;
      return studentModel(
          userId: data['userId'] ?? 'userId',
          province: data['Province'] ?? '',
          uni: data['Uni'] ?? '',
          year: data['Year'] ?? '',
          payment: data['Payment'] ?? '');
    }).toList();
  }

  Stream<List<studentModel>> get studentsStream {
    return _reference.snapshots().map((doc) {
      print('Received student snapshot: ${doc.docs.length} documents');
      return _helper(doc);
    });
  }}*/

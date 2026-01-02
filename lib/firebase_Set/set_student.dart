import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:lindelany/Constants/lists.dart';
import '../classes/student_model.dart';

class StudentProvider extends ChangeNotifier {
  StudentModel? _currentStudent;

  StudentModel? get currentStudentInfo => _currentStudent;

  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'StudentForm',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<StudentModel?> currentStudent({
    Source source = Source.serverAndCache,
  }) async {
    String userId = _auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      _currentStudent = null;
      notifyListeners();
      return null;
    }

    DocumentSnapshot<Object?>? doc;
    final GetOptions options = GetOptions(source: source);

    try {
      // Fetch with the provided source option
      doc = await _reference.doc(userId).get(options);

      // If cache-only failed or returned no data, try server as fallback
      if (source == Source.cache && (!doc.exists || doc.data() == null)) {
        doc = await _reference
            .doc(userId)
            .get(const GetOptions(source: Source.server));
      }

      // Process the document if it exists and has data
      if (doc.exists && doc.data() != null) {
        _currentStudent = StudentModel.fromDocument(doc);
      } else {
        _currentStudent = null;
      }
    } catch (e) {
      //      debugPrint('Error fetching student data: $e');
      _currentStudent = null;
    }

    notifyListeners();
    return _currentStudent;
  }

  // Clear student data on logout
  void clearStudent() {
    _currentStudent = null;
    notifyListeners();
  }

  // Stream of current student, updates Hive when new data arrives
  Stream<StudentModel> currentStudentDoc() {
    String userId = _auth.currentUser!.uid;

    return _reference.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        final fallback = StudentModel(
          userId: '-',
          province: '-',
          uni: 'University',
          year: '-',
          payment: '-',
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
      //      //       print('Received student snapshot: ${doc.docs.length} documents');
      return _helper(doc);
    });
  }

  //----------------------------create student----------------------------------

  Future createStudent(String userId) async {
    try {
      _reference.doc(_auth.currentUser!.uid).set({
        'userId': userId,
        'Province': provinces.first,
        'Uni': southAfricanUniversities.first,
        'Year': YearOfStudy.first,
        'Payment': Payment.first,
      });
    } catch (e) {}
  }
}

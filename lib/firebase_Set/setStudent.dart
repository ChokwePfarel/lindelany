import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../classes/student_model.dart';

class StudentProvider extends ChangeNotifier {
  StudentModel? _currentStudent;

  StudentModel? get currentUser => _currentStudent;

  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'StudentForm',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> currentStudent() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    DocumentSnapshot<Object?>? doc;
    try {
      doc = await _reference
          .doc(userId)
          .get(const GetOptions(source: Source.cache));

      if (!doc.exists || doc.data() == null) {
        doc = await _reference
            .doc(userId)
            .get(const GetOptions(source: Source.server));
      }
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    }


    if (doc == null || !doc.exists || doc.data() == null) {
      print('Using fallback: a student');
      _currentStudent = StudentModel(
        userId: 'current student id',
        province: 'province',
        uni: '',
        year: '1st',
        payment: 'Payment',
      );
    } else {
        _currentStudent = StudentModel.fromDocument(doc);
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
          province: 'province',
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


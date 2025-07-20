import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../broadcast_vehicle_model.dart';

class CreateTransport extends ChangeNotifier {
  vehicleModel? _vehicle;

  vehicleModel? get vehicleProfile => _vehicle;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Vehicle',
  );

  Future<void> createVehicleProfile(
    String carName,
    String brand,
    String numberPlate,
    String numbers,
    String plan,
    double amount,
    String paymentId,
    DateTime createdAt,
    DateTime paymentExpiryDate,
    bool priority,
  ) async {
    try {
      final String userId = _auth.currentUser!.uid;
      await _reference.doc(userId).set({
        'userId': userId,
        'carName': carName,
        'brand': brand,
        'numberPlate': numberPlate,
        'numbers': numbers,
        'plan': plan,
        'amount': amount,
        'paymentId': paymentId,
        'createdAt': Timestamp.fromDate(createdAt), // Convert to Timestamp
        'paymentExpiryDate': Timestamp.fromDate(paymentExpiryDate), // Convert to Timestamp
        'priority': priority,
      });
    } catch (e) {
      print('Error $e');
    }
  }

  Future FetchVehicleProfile() async {
    final String documentID = _auth.currentUser!.uid;
    DocumentSnapshot<Object?>? doc;

    try {
      doc = await _reference
          .doc(documentID)
          .get(const GetOptions(source: Source.cache));

      if (!doc.exists || doc.data() == null) {
        doc = await _reference
            .doc(documentID)
            .get(const GetOptions(source: Source.server));
      }
    } catch (e) {
      print('Error fetching vehicle profile $e');
    }

    // Only assign _user if doc is valid
    if (doc != null && doc.exists && doc.data() != null) {
      _vehicle = vehicleModel.fromDocument(doc);
    } else {
      print("User doc is null or invalid");
      _vehicle = null;
    }

    notifyListeners();
  }

  Stream<vehicleModel> userVehicle() {
    final String documentID = _auth.currentUser!.uid;
    return _reference.doc(documentID).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return vehicleModel(
          docID: '',
          brand: '',
          carName: '',
          numberPlate: '',
          numbers: '',
          paymentId: '',
          plan: '',
          amount: 0.0,
          createdAt: DateTime.now(),
          paymentExpiryDate: DateTime.now(),
          priority: false,
        );
      }

      return vehicleModel.fromDocument(doc);
    });
  }

  List<vehicleModel> _helper(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      if (!doc.exists || doc.data() == null) {
        return vehicleModel(
          docID: '',
          brand: '',
          carName: '',
          numberPlate: '',
          numbers: '',
          paymentId: '',
          plan: '',
          amount: 0.0,
          createdAt: DateTime.now(),
          paymentExpiryDate: DateTime.now(),
          priority: false,
        );
      }

      return vehicleModel.fromDocument(doc);
    }).toList();
  }

  Stream<List<vehicleModel>> get allVehicles {
    return _reference.snapshots().map((snapshot) {
      return _helper(snapshot);
    });
  }


}

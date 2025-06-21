import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../broadcast_vehicle_model.dart';

class createTransport{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection('Vehicle');

  Future<void> createVehicleProfile(String carName,String brand,String numberPlate,String numbers,
      bool hasPaid,String plan,double amount, String paymentId, DateTime createdAt)
  async {
    try{

      final String userId = _auth.currentUser!.uid;
       await _reference.doc(userId).set({
        'userId': userId,
        'carName':carName,
        'brand':brand,
        'numberPlate':numberPlate,
        'numbers':numbers,
        'hasPaid': hasPaid,   //ACTIVATE WHEN PAID IS TRUE
        'plan': plan,
        'amount':amount,
        'paymentId': paymentId,
         'createdAt': createdAt,

      });
    } catch (e){
      print('Error $e');
    }
  }


  Stream<vehicleModel> userVehicle(documentID){
    return _reference.doc(documentID).snapshots().map((doc){

      if(!doc.exists||doc.data() == null){
        return vehicleModel(
            Uid: '',
            docID: '',
            brand: '',
            carName: '',
            numberPlate: '',
            numbers: '',
            paymentId:'',
            plan: '',
            amount: 0.0,
            hasPaid: false,
            createdAt: DateTime.now()
        );
      }

      var data = doc.data() as Map<String, dynamic>;
      return vehicleModel.fromDocument(doc);
    });
  }

  List<vehicleModel> _helper(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){

      if(!doc.exists||doc.data() == null){
        return vehicleModel(
            Uid: '',
            docID: '',
            brand: '',
            carName: '',
            numberPlate: '',
            numbers: '',
            paymentId:'',
            plan: '',
            amount: 0.0,
            hasPaid: false,
            createdAt: DateTime.now()
        );
      }

      return vehicleModel.fromDocument(doc);
    }).toList();
  }

  Stream<List<vehicleModel>> get allVehicles{
    return _reference.snapshots().map((snapshot){
      return _helper(snapshot);
    });
  }

/*
  Stream<List<vehicleModel>> get currentUserCars{
    return _reference.where('userId',isEqualTo: _auth.currentUser!.uid).snapshots().
    map((snapshot){

      return _helper(snapshot);
    });
  }
*/



}

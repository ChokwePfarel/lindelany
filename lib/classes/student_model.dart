import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';


class StudentModel extends HiveObject {
  final String userId;
  final String province;
  final String uni;
  final String year;
  final String payment;

  StudentModel({
    required this.userId,
    required this.province,
    required this.uni,
    required this.year,
    required this.payment
  });
  
  factory StudentModel.fromDocument(DocumentSnapshot doc){
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      userId: data['userId'],
        province: data['Province'],
        uni: data['Uni'],
        year: data['Year'],
        payment: data['Payment']);
  }


  StudentModel copy(){
    return StudentModel(userId: userId,
        province: province,
        uni: uni,
        year: year,
        payment: payment);
  }
}

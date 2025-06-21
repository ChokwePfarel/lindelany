import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastModel {
  final String userId;
  final String postId;
  final String senderName;
  final String broadcast;
  final List<String> images;
  final String uni;
  final Timestamp createdAt;
  late final bool completed;

  BroadcastModel({
    required this.userId,
    required this.postId,
    required this.senderName,
    required this.broadcast,
    required this.images,
    required this.uni,
    required this.createdAt,
    required this.completed,
  });

  factory BroadcastModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BroadcastModel(
      userId: data['userId'] ??'',
      postId: data['postId']??'',
      senderName: data['userName']??'',
      broadcast: data['message']??'',

      images: (data['imageUrls'] is String)
          ? (data['imageUrls'] as String).split(',')
          : (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],

      uni: data['institution']??'',
      createdAt: data['createdAt'] ?? DateTime.now(),
      completed: data['completed'] ?? false,
    );
  }
}







//---------------------------------------------------------------TRANSPORT MODEL
class vehicleModel {
  final String Uid;
  final String docID;
  final String carName;
  final String brand;
  final String numberPlate;
  final String numbers;
  final bool hasPaid;
  final String plan;
  final double amount;
  final String paymentId;
  final DateTime createdAt;

  vehicleModel({
    required this.Uid,
    required this.docID,
    required this.brand,
    required this.carName,
    required this.numberPlate,
    required this.numbers,
    required this.paymentId,
    required this.plan,
    required this.amount,
    required this.hasPaid,
    required this.createdAt,
  });

  factory vehicleModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return vehicleModel(
      Uid: data['userId'],
      docID: data['docId'],
      brand: data['brand'],
      carName: data['carName'],
      numberPlate: data['numberPlate'],
      numbers: data['numbers'],
      paymentId: data['paymentId'],
      plan: data['plan'],
      amount: data['amount'],
      hasPaid: data['hasPaid'],
      createdAt: data['createdAt'],
    );
  }
}

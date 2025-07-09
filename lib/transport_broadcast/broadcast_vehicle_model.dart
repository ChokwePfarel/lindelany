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
  final String docID;
  final String carName;
  final String brand;
  final String numberPlate;
  final String numbers;
  final String plan;
  final double amount;
  final String paymentId;
  final DateTime createdAt;
  final DateTime paymentExpiryDate;
  final bool priority;

  vehicleModel({
    required this.docID,
    required this.brand,
    required this.carName,
    required this.numberPlate,
    required this.numbers,
    required this.paymentId,
    required this.plan,
    required this.amount,
    required this.createdAt,
    required this.paymentExpiryDate,
    required this.priority,
  });

  factory vehicleModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return vehicleModel(
      docID: data['docId']??"",
      brand: data['brand']??"",
      carName: data['carName'] ??"",
      numberPlate: data['numberPlate'] ??' ',
      numbers: data['numbers'] ?? '',
      paymentId: data['paymentId'] ?? '',
      plan: data['plan']?? '',
      amount: data['amount'] ?? 0,
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentExpiryDate: (doc['paymentExpiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: data['priority'] ?? false,

    );
  }

  /*
  factory vehicleModel.fromJson(Map<String, dynamic> json) {
    return vehicleModel(
      Uid: json['userId'] ?? '',
      docID: json['docId'] ?? '',
      brand: json['brand'] ?? '',
      carName: json['carName'] ?? '',
      numberPlate: json['numberPlate'] ?? '',
      numbers: json['numbers'] ?? '',
      paymentId: json['paymentId'] ?? '',
      plan: json['plan'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentExpiryDate: (json['paymentExpiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: json['priority'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': Uid,
      'docId': docID,
      'brand': brand,
      'carName': carName,
      'numberPlate': numberPlate,
      'numbers': numbers,
      'paymentId': paymentId,
      'plan': plan,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentExpiryDate': Timestamp.fromDate(paymentExpiryDate),
      'priority': priority,
    };
  }*/
}

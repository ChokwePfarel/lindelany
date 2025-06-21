import 'package:cloud_firestore/cloud_firestore.dart';
import '../Constants/Lists.dart';

class Listing_model {
  final String userId;
  final String accommodationId;
  final String accommodationName;
  final String location;
  final String targetInstitution;
  final bool isNsfas;
  final bool isWifi;
  final bool isParking;
  final String phoneNumbers;
  final String aboutAccom;
  final bool isFull;
  final double singleRoomPrice;
  final double doubleRoomPrice;
  final String provinces;
  final String genders;
  final String typeOfAccom;
  final String availableRooms;
  final String aboutPayment;
  final bool laundry;
  final bool tv;
  final bool security;
  final bool transport;
  final bool kitchen;
  final bool shower;
  final bool bed;
  final List<String> imageUrls;
  String pictureUrl;
  final bool isTexted;
  final String plan;
  final double amount;
  final String paymentId;
  final DateTime createdAt;
  final DateTime? paymentExpiryDate;
  final bool hasPaid;
  //final bool hasFreeTrial;

  Listing_model({
    required this.userId,
    required this.accommodationId,
    required this.accommodationName,
    required this.location,
    required this.targetInstitution,
    required this.isNsfas,
    required this.isWifi,
    required this.isParking,
    required this.phoneNumbers,
    required this.aboutAccom,
    required this.isFull,
    required this.singleRoomPrice,
    required this.doubleRoomPrice,
    required this.provinces,
    required this.genders,
    required this.typeOfAccom,
    required this.availableRooms,
    required this.aboutPayment,
    required this.laundry,
    required this.tv,
    required this.security,
    required this.transport,
    required this.kitchen,
    required this.shower,
    required this.bed,
    required this.imageUrls,
    required this.pictureUrl,
    required this.plan,
    required this.amount,
    required this.paymentId,
    required this.createdAt,
    required this.isTexted,
    required this.paymentExpiryDate,
    required this.hasPaid,
    //required this.hasFreeTrial,
  });

  factory Listing_model.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Listing_model(
      userId: data['userId'],
      accommodationId: data['accommodationId'],
      accommodationName: data['accommodationName'] ?? '',
      location: data['location'] ?? '',
      targetInstitution:
      data['targetInstitution'] ?? southAfricanUniversities.first,
      aboutAccom: data['aboutAccom'] ?? '',
      phoneNumbers: data['phoneNumbers'] ?? '',
      isNsfas: data['isNsfas'] ?? false,
      isWifi: data['isWIFI'] ?? false,
      isParking: data['isParking'] ?? false,
      isFull: data['isFull'] ?? true,
      singleRoomPrice: data['singleRoomPrice'] ?? 0.0,
      doubleRoomPrice: data['doubleRoomPrice'] ?? 0.0,
      provinces: data['provinces'] ?? '',
      genders: data['genders'] ?? '',
      typeOfAccom: data['typeOfAccom'] ?? '',
      availableRooms: data['availableRooms'] ?? '',
      aboutPayment: data['aboutPayment'] ?? '',
      laundry: data['laundry'] ?? false,
      tv: data['tv'] ?? false,
      security: data['security'] ?? false,
      transport: data['transport'] ?? false,
      kitchen: data['kitchen'] ?? false,
      shower: data['shower'] ?? false,
      bed: data['bed'] ?? false,
      imageUrls: (data['imageUrls'] is String)
          ? (data['imageUrls'] as String).split(',')
          : (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],

      pictureUrl: (data['pictureUrl'] as String?)?.isNotEmpty == true
          ? data['pictureUrl'] as String
          : "assets/houseFallBack.jpg",

      plan: data['plan'] ?? '',

      amount: data['amount'] ?? 0.0,
      paymentId: data['paymentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentExpiryDate: (data['paymentExpiryDate'] as Timestamp).toDate(),
      isTexted: data['isTexted'] ?? false,
      hasPaid: data['hasPaid'] ?? false,
      //hasFreeTrial: data['hasFreeTrial'] ?? true,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accommodationId': accommodationId,
      'accommodationName': accommodationName,
      'location': location,
      'targetInstitution': targetInstitution,
      'isNsfas': isNsfas,
      'isWifi': isWifi,
      'isParking': isParking,
      'phoneNumbers': phoneNumbers,
      'aboutAccom': aboutAccom,
      'isFull': isFull,
      'singleRoomPrice': singleRoomPrice,
      'doubleRoomPrice': doubleRoomPrice,
      'provinces': provinces,
      'genders': genders,
      'typeOfAccom': typeOfAccom,
      'availableRooms': availableRooms,
      'aboutPayment': aboutPayment,
      'laundry': laundry,
      'tv': tv,
      'security': security,
      'transport': transport,
      'kitchen': kitchen,
      'shower': shower,
      'bed': bed,
      'imageUrls': imageUrls,
      'pictureUrl': pictureUrl,
      'plan': plan,
      'amount': amount,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      'paymentExpiryDate': paymentExpiryDate?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'isTexted': isTexted,
      'hasPaid': hasPaid,
    };
  }

  factory Listing_model.fromJson(Map<String, dynamic> json) {
    return Listing_model(
      userId: json['userId'],
      accommodationId: json['accommodationId'],
      accommodationName: json['accommodationName'],
      location: json['location'],
      targetInstitution: json['targetInstitution'],
      isNsfas: json['isNsfas'],
      isWifi: json['isWifi'],
      isParking: json['isParking'],
      phoneNumbers: json['phoneNumbers'],
      aboutAccom: json['aboutAccom'],
      isFull: json['isFull'],
      singleRoomPrice: json['singleRoomPrice'],
      doubleRoomPrice: json['doubleRoomPrice'],
      provinces: json['provinces'],
      genders: json['genders'],
      typeOfAccom: json['typeOfAccom'],
      availableRooms: json['availableRooms'],
      aboutPayment: json['aboutPayment'],
      laundry: json['laundry'],
      tv: json['tv'],
      security: json['security'],
      transport: json['transport'],
      kitchen: json['kitchen'],
      shower: json['shower'],
      bed: json['bed'],
      imageUrls: List<String>.from(json['imageUrls']),
      pictureUrl: json['pictureUrl'],
      plan: json['plan'],
      amount: json['amount'],
      paymentId: json['paymentId'],
      createdAt: DateTime.parse(json['createdAt']), // Parse ISO 8601 string back to DateTime
      paymentExpiryDate: json['paymentExpiryDate'] != null ? DateTime.parse(json['paymentExpiryDate']) : null, // Handle nullable
      isTexted: json['isTexted'],
      hasPaid: json['hasPaid'],
    );
  }
}
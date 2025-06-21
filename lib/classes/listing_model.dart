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
}

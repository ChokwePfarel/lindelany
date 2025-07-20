import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {

  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String userName;
  @HiveField(2)
  final String userType;
  @HiveField(3)
  final String userGender;
  @HiveField(4)
  String profilePictureUrl;
  @HiveField(5)
  final bool isFreeTrial;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userType,
    required this.userGender,
    required this.profilePictureUrl,
    required this.isFreeTrial,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userType: data['userType'] ?? '',
      userGender: data['userGender'] ?? '',
      profilePictureUrl:
          (data['profilePictureUrl'] is String &&
              (data['profilePictureUrl'] as String).isNotEmpty)
          ? data['profilePictureUrl'] as String
          : "assets/person1.png",
      isFreeTrial: data['isFreeTrial'] ?? false,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'userGender': userGender,
      'profilePictureUrl': profilePictureUrl,
      'isFreeTrial': isFreeTrial,
    };
  }


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userType: json['userType'] ?? '',
      userGender: json['userGender'] ?? '',
      profilePictureUrl:
          (json['profilePictureUrl'] is String &&
              (json['profilePictureUrl'] as String).isNotEmpty)
          ? json['profilePictureUrl'] as String
          : "assets/person1.png",
      isFreeTrial: json['isFreeTrial'] ?? false,
    );
  }

  // Method to convert UserModel to a Map (useful for updating user data in Firestore)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'userGender': userGender,
      'profilePictureUrl': profilePictureUrl,
      'isFreeTrial': isFreeTrial,
    };
  }

  // Method to create a copy of the UserModel with optional changed values
  UserModel copyWith({
    String? userId,
    String? userName,
    String? userType,
    String? userGender,
    String? profilePictureUrl,
    bool? isFreeTrial,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userType: userType ?? this.userType,
      userGender: userGender ?? this.userGender,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isFreeTrial: isFreeTrial ?? this.isFreeTrial,
    );
  }
}

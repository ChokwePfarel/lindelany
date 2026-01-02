import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final List<String> participants; // List of user UIDs in the chat
  final String lastMessage; // The content of the last message
  final String lastMessageSenderId; // The ID of the sender of the last message
  final DateTime? lastMessageTimestamp; // Made it nullable for sorting purpose/wen user deleted all messages
  //not required on constra to avoid null error
  final Map<String, dynamic> lastMessageData; // Full data of the last message, useful for type

  ChatRoomModel({
    required this.chatRoomId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.lastMessageTimestamp,
    required this.lastMessageData,
  });

  // Factory constructor to create a ChatRoomModel from a Firestore DocumentSnapshot
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Safely parse DateTime from Firestore Timestamp
    final timestamp = json['lastMessageTimestamp'] == null
        ? null
        : (json['lastMessageTimestamp'] as Timestamp).toDate();


    return ChatRoomModel(
      chatRoomId: json['chatRoomId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []), // Ensure it's a List<String>
      lastMessage: json['lastMessage'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      lastMessageTimestamp: timestamp,
      lastMessageData: Map<String, dynamic>.from(json['lastMessageData'] ?? {}),
    );
  }

  // Method to convert ChatRoomModel instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp': lastMessageTimestamp == null
          ? null
          : Timestamp.fromDate(lastMessageTimestamp!),

      'lastMessageData': lastMessageData,
    };
  }


}

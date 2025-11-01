import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final List<String> participants; // List of user UIDs in the chat
  final String lastMessage; // The content of the last message
  final String lastMessageSenderId; // The ID of the sender of the last message
  final DateTime lastMessageTimestamp; // Timestamp of the last message
  final Map<String, dynamic> lastMessageData; // Full data of the last message, useful for type

  ChatRoomModel({
    required this.chatRoomId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTimestamp,
    required this.lastMessageData,
  });

  // Factory constructor to create a ChatRoomModel from a Firestore DocumentSnapshot
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Safely parse DateTime from Firestore Timestamp
    DateTime timestamp;
    if (json['lastMessageTimestamp'] is Timestamp) {
      timestamp = (json['lastMessageTimestamp'] as Timestamp).toDate();
    } else {
      // Fallback for cases where timestamp might be missing or not a Timestamp
      timestamp = DateTime.now(); // Or handle error appropriately
//       print("Warning: lastMessageTimestamp not found or not a Timestamp in ChatRoomModel.fromJson for chatRoomId: ${json['chatRoomId']}");
    }

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
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'lastMessageData': lastMessageData,
    };
  }

  // You might also want a copyWith method for immutability
  ChatRoomModel copyWith({
    String? chatRoomId,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, dynamic>? lastMessageData,
  }) {
    return ChatRoomModel(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageData: lastMessageData ?? this.lastMessageData,
    );
  }
}

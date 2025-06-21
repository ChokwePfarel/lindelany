import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class MessageModel extends HiveObject {

  final String messageId;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timeStamp;
  final String status;
  final String type; // e.g., 'text', 'image', 'audio'
  final String chatRoomId; // Link message directly to its chat room

  MessageModel({
    required this.messageId,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timeStamp,
    required this.status,
    required this.type, // Added to constructor
    required this.chatRoomId, // Added to constructor
  });

  // Renamed to `toJson` for standard serialization to Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      "messageId": messageId,
      "receiverId": receiverId,
      "senderId": senderId,
      "senderName": senderName,
      "message": message,
      "timeStamp": timeStamp,
      "status": status,
      "type": type, // Added to JSON
      "chatRoomId": chatRoomId, // Added to JSON
    };
  }

  // Renamed to `fromJson` for standard deserialization from Map (from Firestore)
  factory MessageModel.fromJson(Map<String, dynamic> data) {
    return MessageModel(
      messageId: data['messageId'], // Use the field from data
      receiverId: data['receiverId'],
      senderId: data['senderId'],
      senderName: data['senderName'],
      message: data['message'],
      timeStamp: (data['timeStamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'sent', // Default to 'sent' if status is missing
      type: data['type'] ?? 'text', // Default to 'text' if type is missing
      chatRoomId: data['chatRoomId'], // Get chatRoomId from data
    );
  }

  // Updated copyWith to include new fields
  MessageModel copyWith({
    String? messageId,
    String? receiverId,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timeStamp,
    String? status,
    String? type,
    String? chatRoomId,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timeStamp: timeStamp ?? this.timeStamp,
      status: status ?? this.status,
      type: type ?? this.type,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }
}
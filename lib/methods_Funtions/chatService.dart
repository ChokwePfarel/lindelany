import 'dart:async'; // For Completer
// Only if you need BuildContext within ChatServices, otherwise remove
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

import '../classes/chatRoomModel.dart';
import '../classes/message_model.dart';



// Ensure this path is correct
// Ensure this path is correct

/// A service class for handling chat-related operations with Firestore.
/// This class uses a singleton pattern to ensure only one instance exists.
class ChatServices {
  // Singleton instance
  static final ChatServices _instance = ChatServices._internal();

  // Factory constructor to return the singleton instance
  factory ChatServices() => _instance;

  // Internal constructor for the singleton
  ChatServices._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Cache for messages (optional, can be expanded for more sophisticated caching)
  final Map<String, List<MessageModel>> _cachedMessages = {};

  // Global event system for unread message notifications
  static final BehaviorSubject<bool> _unreadMessagesSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get unreadMessagesStream => _unreadMessagesSubject.stream;

  /// Helper to update the global unread status.
  void _updateUnreadStatus(bool hasUnread) {
    _unreadMessagesSubject.add(hasUnread);
  }

  /// Sends a message to a specified receiver in a given chat room.
  ///
  /// This method handles both new and existing chat rooms. For new chat rooms,
  /// it uses a Firestore batch write to atomically create the chat room document
  /// and the first message, ensuring consistency and adherence to security rules.
  ///
  /// [receiverId]: The ID of the user receiving the message.
  /// [messageText]: The content of the message.
  /// [chatRoomId]: The ID of the chat room.
  Future<void> sendMessage(String receiverId, String messageText, String chatRoomId) async {
    final currentUser = _auth.currentUser; // Get current user here
    if (currentUser == null) {
      debugPrint("ChatPage: ERROR - No current user logged in when trying to send message.");
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text("You must be logged in to send messages."))
      );
      return; // Exit if no user
    }

    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    // Fetch sender's username (assuming 'Users' collection exists)
    String senderName = 'Unknown User';
    try {
      DocumentSnapshot senderDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
      if (senderDoc.exists && senderDoc.data() is Map<String, dynamic>) {
        final data = senderDoc.data() as Map<String, dynamic>;
        senderName = data['userName'] ?? 'Unknown User';
      }
    } catch (e) {
//       print("Warning: Could not fetch sender's username: $e");
    }

    final message = MessageModel(
      messageId: messageId,
      senderId: currentUser.uid,
      senderName: senderName,
      receiverId: receiverId,
      message: messageText,
      timeStamp: timestamp,
      status: 'sending', // Initial status
      type: 'text',
      chatRoomId: chatRoomId,
    );

    try {
      // Check if the chat room document already exists
      final chatRoomRef = _firestore.collection('chatRoomIds').doc(chatRoomId);
      final chatRoomDocSnapshot = await chatRoomRef.get();
      final chatRoomExists = chatRoomDocSnapshot.exists;

      if (!chatRoomExists) {
        // --- Best Practice: Use a batch write for new chat rooms ---
        WriteBatch batch = _firestore.batch();

        //For debugging
        final chatRoomRef = _firestore.collection('chatRoomIds').doc(chatRoomId);
//         print('ChatService: Preparing to create new chat room and first message via batch.');
//         print('ChatService: chatRoomId: $chatRoomId');
//         print('ChatService: Participants: [${currentUser.uid}, $receiverId]');

        // 1. Set the chat room document (creates it if it doesn't exist)
        batch.set(chatRoomRef, {
          'participants': [currentUser.uid, receiverId],
          'lastMessage': message.message,
          'lastMessageTimestamp': message.timeStamp,
          'lastMessageSenderId': currentUser.uid,
          'lastMessageData': {
            'status': 'sent', // Mark as sent immediately for the last message summary
            'type': 'text',
            'receiverId': receiverId,
          },
          'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
        });

        // 2. Add the first message to the messages subcollection
        // We set the status to 'sent' directly here as it's part of the atomic commit
        final messageDocRef = chatRoomRef.collection('messages').doc();
        final sentMessage = message.copyWith(messageId: messageDocRef.id, status: 'sent');
        batch.set(messageDocRef, sentMessage.toJson());

        // Commit the batch operation
        await batch.commit();

        // Update local cache after successful batch commit
        final cached = _cachedMessages[chatRoomId] ?? [];
        _cachedMessages[chatRoomId] = [...cached, sentMessage];

//         print('New chat room and first message sent successfully via batch: ${message.messageId}');
      } else {
        // --- Existing chat room: Perform individual operations ---
        // 1. Add the message to the messages subcollection
        final docRef = await chatRoomRef.collection('messages').add(message.toJson());

        // 2. Update the message status and ID (optional, can be done in initial add if preferred)
        await chatRoomRef.collection('messages').doc(docRef.id).update({
          'status': 'sent',
          'messageId': docRef.id, // Ensure messageId is stored in Firestore
        });

        // 3. Update the last message details in the chat room document
        await chatRoomRef.set({
          'lastMessage': message.message,
          'lastMessageTimestamp': message.timeStamp,
          'lastMessageSenderId': currentUser.uid,
          'lastMessageData': {
            'status': 'sent',
            'type': 'text',
            'receiverId': receiverId,
          }
        }, SetOptions(merge: true));

        // Update local cache
        final sentMessage = message.copyWith(messageId: docRef.id, status: 'sent');
        final cached = _cachedMessages[chatRoomId] ?? [];
        _cachedMessages[chatRoomId] = [...cached, sentMessage];

//         print('Message sent successfully to existing chat: ${message.messageId}');
      }
    } catch (e) {
//       print('ChatService: Batch commit FAILED for new chat room $chatRoomId: $e');
      // Re-throw the error so it can be caught by the UI
      rethrow;
//       print("Error sending message to Firestore: $e");
      // For a robust app, you might still want a *different* queuing/retry
      // mechanism here for general network failures, but not for the
      // new chat room creation race condition.
      // For now, just log the error.
    }
  }

  /// Retrieves a stream of messages for a given chat room.
  /// Messages are ordered by timestamp.
  ///
  /// [chatRoomId]: The ID of the chat room.
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
//       print("Warning: No current user logged in. Returning empty message stream.");
      return Stream.value([]);
    }

    return _firestore
        .collection('chatRoomIds')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final firestoreMessages = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();

      // Update cache with the latest messages from Firestore
      _cachedMessages[chatRoomId] = firestoreMessages;

      return firestoreMessages;
    }).onErrorReturnWith((error, stackTrace) {
//       print('Error fetching messages for chat room $chatRoomId: $error');
      // Return cached messages if an error occurs during fetching
      return _cachedMessages[chatRoomId] ?? [];
    });
  }

  /// Retrieves a stream of chat rooms that a user is a participant in.
  /// This also triggers a check for unread messages.
  ///
  /// [userId]: The ID of the current user.
  Stream<List<ChatRoomModel>> getChatRoomsStream(String userId) {
    return _firestore
        .collection('chatRoomIds')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs.map((doc) => ChatRoomModel.fromJson(doc.data())).toList();
      _checkForUnreadMessages(userId, rooms); // Check and notify about unread messages
      return rooms;
    });
  }

  /// Checks for unread messages across all chat rooms for the current user
  /// and updates the global unread status stream.
  ///
  /// [currentUserId]: The ID of the current user.
  /// [rooms]: A list of ChatRoomModel objects.
  void _checkForUnreadMessages(String currentUserId, List<ChatRoomModel> rooms) {
    final hasUnread = rooms.any((room) =>
    room.lastMessageData['status'] == 'sent' &&
        room.lastMessageSenderId != currentUserId &&
        room.lastMessageData['receiverId'] == currentUserId);

    _updateUnreadStatus(hasUnread);
  }

  /// Marks all 'sent' messages in a specific chat room as 'read'.
  ///
  /// [currentUserId]: The ID of the current user.
  /// [otherUserId]: The ID of the other user in the chat.
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final chatRoomRef = _firestore.collection('chatRoomIds').doc(chatRoomId);
      final messagesRef = chatRoomRef.collection('messages');

      // Query for unread messages sent by the other user
      final unreadMessagesSnapshot = await messagesRef
          .where('status', isEqualTo: 'sent')
          .where('senderId', isEqualTo: otherUserId)
          .get();

//       print('Fetched ${unreadMessagesSnapshot.docs.length} unread messages to mark as read.');

      if (unreadMessagesSnapshot.docs.isNotEmpty) {
        // Use a batch to perform both updates atomically
        final batch = _firestore.batch();

        // 1. Update the status of each unread message to 'read'
        for (var doc in unreadMessagesSnapshot.docs) {
          batch.update(doc.reference, {'status': 'read'});
        }

        // 2. Update the parent chat room document's lastMessageData status
        // This is the key change to get the UI to update
        batch.update(chatRoomRef, {
          'lastMessageData.status': 'read',
        });

        // Commit the batch to apply all changes
        await batch.commit();

        _updateUnreadStatus(false);
//         print('Marked ${unreadMessagesSnapshot.docs.length} messages as read, and updated chat room summary.');
      }
    } catch (e) {
//       print('Error marking messages as read: $e');
    }
  }
  /// Disposes of the BehaviorSubjects to prevent memory leaks.
  void dispose() {
    _unreadMessagesSubject.close();
  }
}


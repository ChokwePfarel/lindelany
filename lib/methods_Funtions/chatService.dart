import 'dart:async'; // For Completer
// Only if you need BuildContext within ChatServices, otherwise remove
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../classes/chatRoomModel.dart';
import '../classes/message_model.dart';


class ChatServices {
  static final ChatServices _instance = ChatServices._internal();
  static Completer<void>? _initializationCompleter;

  factory ChatServices() => _instance;

  ChatServices._internal();

  final List<MessageModel> _queuedMessages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  final Map<String, List<MessageModel>> _cachedMessages = {};
  final BehaviorSubject<List<MessageModel>> _queuedMessagesController =
  BehaviorSubject<List<MessageModel>>.seeded([]);




  Future<void> _sendQueuedMessages() async {
    if (_queuedMessages.isEmpty) {
      print("ChatServices: No messages in queue to send.");
      return;
    }

    print("ChatServices: Found ${_queuedMessages.length} messages in queue. Attempting to send...");
    for (final message in List<MessageModel>.from(_queuedMessages)) {
      print("ChatServices: Retrying message: ${message.message}");
      await _sendMessageInternal(message, isQueued: true);
    }
    _updateQueuedMessagesStream();
  }

  void _updateQueuedMessagesStream() {
    _queuedMessagesController.add(List.from(_queuedMessages));
  }

  Future<void> sendMessage(String receiverId, String messageText, String chatRoomId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("Error: No current user logged in.");
      return;
    }

    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    DocumentSnapshot senderDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
    final data = senderDoc.data() as Map<String, dynamic>;
    String senderName = data['userName'] ?? 'Unknown User';

    final message = MessageModel(
      messageId: messageId,
      senderId: currentUser.uid,
      senderName: senderName,
      receiverId: receiverId,
      message: messageText,
      timeStamp: timestamp,
      status: 'sending',
      type: 'text',
      chatRoomId: chatRoomId,
    );

    await _sendMessageInternal(message);
  }

  Future<void> _sendMessageInternal(MessageModel message, {bool isQueued = false}) async {
    final chatRoomId = message.chatRoomId;
    final senderId = message.senderId;
    final receiverId = message.receiverId;

    try {
      final docRef = await _firestore
          .collection('chatRoomIds')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toJson());

      await _firestore
          .collection('chatRoomIds')
          .doc(chatRoomId)
          .collection('messages')
          .doc(docRef.id)
          .update({'status': 'sent', 'messageId': docRef.id});

      final sentMessage = message.copyWith(messageId: docRef.id, status: 'sent');

      await _firestore.collection('chatRoomIds').doc(chatRoomId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message.message,
        'lastMessageTimestamp': message.timeStamp,
        'lastMessageSenderId': senderId,
        'lastMessageData': {
          'status': 'sent',
          'type': 'text',
          'receiverId': receiverId,
        }
      }, SetOptions(merge: true));

      final cached = _cachedMessages[chatRoomId] ?? [];
      _cachedMessages[chatRoomId] = [...cached, sentMessage];

      if (isQueued) {
        _queuedMessages.removeWhere((m) => m.messageId == message.messageId);
        _updateQueuedMessagesStream();
        print('Message successfully sent and removed from queue: ${message.messageId}');
      }
      print('Message sent successfully: ${message.messageId}');
    } catch (e) {
      print("Error sending message to Firestore: $e");
      if (!isQueued && !_queuedMessages.any((m) => m.messageId == message.messageId)) {
        _queuedMessages.add(message.copyWith(status: 'failed'));
        _updateQueuedMessagesStream();
        print('Message failed to send, queued for retry: ${message.messageId}');
      } else if (isQueued) {
        print('Retrying queued message failed again: ${message.messageId}. Keeping in queue.');
      } else {
        print('Message failed to send, but already in queue: ${message.messageId}.');
      }
    }
  }

  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
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

      _cachedMessages[chatRoomId] = firestoreMessages;

      final List<MessageModel> allMessages = [...firestoreMessages];
      final queuedForThisChat = _queuedMessages
          .where((msg) => msg.chatRoomId == chatRoomId)
          .toList();

      for (final qMsg in queuedForThisChat) {
        if (!firestoreMessages.any((fMsg) => fMsg.messageId == qMsg.messageId)) {
          allMessages.add(qMsg);
        }
      }

      allMessages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      return allMessages;
    }).onErrorReturnWith((error, stackTrace) {
      print('Error fetching messages: $error');
      return _queuedMessages
          .where((msg) => msg.chatRoomId == chatRoomId)
          .toList();
    });
  }

  Stream<List<ChatRoomModel>> getChatRoomsStream(String userId) {
    return _firestore
        .collection('chatRoomIds')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoomModel.fromJson(doc.data())
      ).toList();
    });
  }

  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final messagesRef = _firestore
          .collection('chatRoomIds')
          .doc(chatRoomId)
          .collection('messages');

      final unreadMessagesSnapshot = await messagesRef.where('status', isEqualTo: 'sent')
          .get();


      print('fetched unread ${unreadMessagesSnapshot.docs.length}');
      if (unreadMessagesSnapshot.docs.isNotEmpty) {
        print('Unread messages $unreadMessagesSnapshot');
        final batch = _firestore.batch();
        for (var doc in unreadMessagesSnapshot.docs) {
          print(doc.reference.path);
          batch.update(doc.reference, { 'status': 'read',});
        }
        await batch.commit();
        print('Marked ${unreadMessagesSnapshot.docs.length} messages as read.');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void dispose() {
    _queuedMessagesController.close();
  }

  Stream<List<MessageModel>> get queuedMessagesStream => _queuedMessagesController.stream;
}


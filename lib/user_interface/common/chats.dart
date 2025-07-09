import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart' show Hive, Box;
import 'package:intl/intl.dart';
import 'package:lindelany/providers/has_newMessage.dart';
import 'package:provider/provider.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/chatRoomModel.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
import '../../methods_Funtions/chatService.dart';
import '../../utility/utility_class.dart';
import '../landlord/show_atCenter.dart';

class AllChats extends StatefulWidget {
  // Add a field to receive notification data
  final Map<String, dynamic>? notificationData;

  const AllChats({super.key, this.notificationData});

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatServices _chatServices = ChatServices(); // Use a private variable


  late Box<UserModel> _userBox;

  StreamSubscription<List<ChatRoomModel>>? _chatRoomsSubscription;

  // This stream should now fetch ChatRoomModel, not UserModel directly for the list
   Stream<List<ChatRoomModel>>? _chatRoomsStream;

  // This will store a map of userId to UserModel for quick lookup
  Map<String, UserModel> _allUsersMap = {};

  String formatTimeOrDate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays < 1 && now.day == time.day) {
      // Less than 24 hours and same day (today)
      return DateFormat('hh:mm a').format(time);
    } else if (difference.inDays == 1 && now.day != time.day) {
      // Exactly one day difference (yesterday)
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Less than 7 days (within a week)
      return DateFormat('EEE').format(time); // Mon, Tue, etc.
    } else {
      // More than a week
      return DateFormat('dd MMM').format(time); // 01 Jan, 02 Feb, etc.
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeChats();
  }

  Future<void> _initializeChats() async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      debugPrint("User not logged in.");
      _chatRoomsStream = Stream.value([]);
      return;
    }

    _userBox = await Hive.openBox<UserModel>('user_data');

    // Step 1: Preload users from Hive into memory map
    final cachedUsers = _userBox.toMap().cast<String, UserModel>();
    setState(() {
      _allUsersMap = cachedUsers;
    });

    // Step 2: Start listening to chat room stream
    _chatRoomsStream = _chatServices.getChatRoomsStream(currentUserId);

    _chatRoomsSubscription = _chatRoomsStream!.listen((chatRooms) async {
      for (final room in chatRooms) {
        final otherId = room.participants.firstWhere(
              (id) => id != currentUserId,
          orElse: () => '',
        );

        if (otherId.isEmpty || _allUsersMap.containsKey(otherId)) continue;

        // Fetch from Firestore only if not already in cache
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(otherId)
            .get();

        if (userDoc.exists) {
          final user = UserModel.fromDocument(userDoc);
          await _userBox.put(otherId, user); // Cache in Hive
          setState(() {
            _allUsersMap[otherId] = user;
          });
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
        title: Text(
          'Chats',
          style: theme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        // Now using _chatRoomsStream (from ChatServices)
        stream: _chatRoomsStream,
        builder: (context, snapshot) {
          if (AsyncUtils.isLoadingOrError(snapshot)) {
            return AsyncUtils.BuildIsloadingOrError(snapshot);
          }

          final chatRooms = snapshot.data!;
          if (chatRooms.isEmpty) {
            return const Center(child: Text("No chats available."));
          }

          // Sort chat rooms by the latest message timestamp
          chatRooms.sort(
            (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
          );

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];

              // Determine the other participant's ID
              final otherParticipantId = chatRoom.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () =>
                    '', // Fallback if somehow only current user is participant
              );

              // Get the UserModel for the other participant
              final user = _allUsersMap[otherParticipantId];

              // If for some reason the other user's data isn't available, skip or show placeholder
              if (user == null) {
                debugPrint(
                  "AllChats: User data not found for ID: $otherParticipantId",
                );
                return const SizedBox.shrink(); // Hide this chat room if user data is missing
              }

              final timestamp = formatTimeOrDate(chatRoom.lastMessageTimestamp);
              final String displayMessage =
                  chatRoom.lastMessageData['type'] == 'image'
                  ? 'Sent an image' // Or an icon, etc.
                  : (chatRoom.lastMessage.length > 21
                        ? '${chatRoom.lastMessage.substring(0, 21)}...'
                        : chatRoom.lastMessage);

              // Check if the last message was sent by the other user and is not yet read by current user
              final bool isNewMessage =
                  chatRoom.lastMessageSenderId == otherParticipantId &&
                  chatRoom.lastMessageData['status'] == 'sent' &&
                  chatRoom.lastMessageData['receiverId'] == currentUserId;



              return ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    // Preload image before navigation
                    if (user.profilePictureUrl.startsWith('http')) {
                      final imageProvider = NetworkImage(
                        user.profilePictureUrl,
                      );
                      await precacheImage(imageProvider, context);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => showAtCenter(
                          imagesUrl:
                              user.profilePictureUrl, // Pass actual URL
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: user.profilePictureUrl.startsWith('http')
                        ? CachedNetworkImageProvider(user.profilePictureUrl)
                        : AssetImage(user.profilePictureUrl) as ImageProvider,
                    radius: 25,
                  ),
                ),
                title: Text(
                  user.userName,
                  style: theme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      displayMessage,
                      style: theme.bodySmall?.copyWith(
                        color: isNewMessage ? Colors.black : Colors.grey,

                        // Bold/darker for new messages
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 63,
                      child: Text(
                        timestamp,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    isNewMessage
                        ? Icon(
                            Icons.circle_rounded,
                            color: Colors.green,
                            size: 16,
                          )
                        : SizedBox(),
                  ],
                ),
                onTap: () async {
                  //Mark as read
                  Provider.of<chatProvider>(
                    context,
                    listen: false,
                  ).navigateToChat(context, user);

                  if (chatRoom.lastMessageSenderId != currentUserId) {
                    await _chatServices.markMessagesAsRead(
                      currentUserId,
                      otherParticipantId,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    super.dispose();
  }
}

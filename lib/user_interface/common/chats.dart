import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart' show Hive, Box;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Providers/chatProvider.dart';
import '../../classes/chatRoomModel.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/chatService.dart';
// Assuming AsyncUtils is here
import '../landlord/show_atCenter.dart';

class AllChats extends StatefulWidget {
  final Map<String, dynamic>? notificationData;
  const AllChats({super.key, this.notificationData});

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // This preserves the state

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatServices _chatServices = ChatServices();
  late Box<UserModel> _userBox;

  StreamSubscription<List<ChatRoomModel>>? _chatRoomsSubscription;
  Stream<List<ChatRoomModel>>? _chatRoomsStream;

  Map<String, UserModel> _allUsersMap = {};
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    debugPrint('AllChats: initState called.');
    _initializeChatStreamAndUsers();
  }

  Future<void> _initializeChatStreamAndUsers() async {
    debugPrint('AllChats: _initializeChatStreamAndUsers called.');
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("AllChats: User not logged in.");
      setState(() {
        _chatRoomsStream = Stream.value([]);
        _isLoadingUsers = false;
      });
      return;
    }

    try {

        _userBox = await Hive.openBox<UserModel>('user_data');
      final cachedUsers = _userBox.toMap().cast<String, UserModel>();
      setState(() {
        _allUsersMap = cachedUsers;
        _isLoadingUsers = false;
      });
      debugPrint('AllChats: Hive box opened and cached users loaded. Count: ${_allUsersMap.length}');


      // Only assign the stream if it hasn't been assigned yet (or explicitly reset for refresh)
      if (_chatRoomsStream == null) {
        _chatRoomsStream = _chatServices.getChatRoomsStream(currentUserId);
        debugPrint('AllChats: _chatRoomsStream assigned.');
      } else {
        debugPrint('AllChats: _chatRoomsStream already exists.');
      }


      // Cancel existing subscription before creating a new one to prevent duplicates
      _chatRoomsSubscription?.cancel();
      _chatRoomsSubscription = null; // Clear the old subscription reference

      // Start a new subscription only if the stream is available
      if (_chatRoomsStream != null) {
        _chatRoomsSubscription = _chatRoomsStream!.listen((chatRooms) async {
          debugPrint('AllChats: Stream listener received ${chatRooms.length} chat rooms.');
          final List<String> userIdsToFetch = [];
          for (final room in chatRooms) {
            final otherId = room.participants.firstWhere(
                  (id) => id != currentUserId,
              orElse: () => '',
            );
            if (otherId.isNotEmpty && !_allUsersMap.containsKey(otherId)) {
              userIdsToFetch.add(otherId);
            }
          }

          if (userIdsToFetch.isNotEmpty) {
            debugPrint('AllChats: Fetching ${userIdsToFetch.length} missing users.');
            final List<UserModel> fetchedUsers = [];
            for (final userId in userIdsToFetch) {
              final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
              if (userDoc.exists) {
                final user = UserModel.fromDocument(userDoc);
                fetchedUsers.add(user);
                await _userBox.put(userId, user);
              }
            }
            if (fetchedUsers.isNotEmpty) {
              setState(() {
                for (final user in fetchedUsers) {
                  _allUsersMap[user.userId] = user;
                }
                debugPrint('AllChats: Updated _allUsersMap with ${fetchedUsers.length} new users.');
              });
            }
          }
        }, onError: (error) {
          debugPrint("AllChats: Error in chatRoomsStream listener: $error");
        }, onDone: () {
          debugPrint("AllChats: ChatRooms stream is done.");
        });
        debugPrint('AllChats: Stream subscription established.');
      }

    } catch (e) {
      debugPrint("AllChats: Error initializing chats: $e");
      setState(() {
        _chatRoomsStream = Stream.value([]);
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _refreshChats() async {
    debugPrint('AllChats: _refreshChats called.');
    // Cancel existing subscription
    await _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = null;

    // Clear cached users and reset loading state
    setState(() {
      _allUsersMap.clear();
      _isLoadingUsers = true;
      _chatRoomsStream = null; // Force re-assignment of the stream
    });

    // Re-initialize everything
    await _initializeChatStreamAndUsers();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint('AllChats: build called.');
    final theme = Theme.of(context).textTheme;
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      debugPrint('AllChats: Building with no current user.');
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("User not logged in.")),
      );
    }

    if (_isLoadingUsers || _chatRoomsStream == null) {
      debugPrint('AllChats: Building with loading indicator (isLoadingUsers: $_isLoadingUsers, _chatRoomsStream == null: ${_chatRoomsStream == null}).');
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshChats();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Refresh Chats'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChats,
        child: StreamBuilder<List<ChatRoomModel>>(
          stream: _chatRoomsStream,
          builder: (context, snapshot) {
            debugPrint('AllChats: StreamBuilder building. ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint("AllChats: StreamBuilder error: ${snapshot.error}");
              return Center(child: Text("Error loading chats: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No chats available."));
            }

            final chatRooms = snapshot.data!;
            chatRooms.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));

            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                final otherParticipantId = chatRoom.participants.firstWhere(
                      (id) => id != currentUserId,
                  orElse: () => '',
                );

                final user = _allUsersMap[otherParticipantId];
                if (user == null) {
                  debugPrint("AllChats: User data not found for ID: $otherParticipantId. This chat might not display correctly.");
                  return const SizedBox.shrink();
                }

                final timestamp = formatTimeOrDate(chatRoom.lastMessageTimestamp);
                final String displayMessage = chatRoom.lastMessageData['type'] == 'image'
                    ? 'Sent an image'
                    : (chatRoom.lastMessage.length > 21
                    ? '${chatRoom.lastMessage.substring(0, 21)}...'
                    : chatRoom.lastMessage);

                final bool isNewMessage = chatRoom.lastMessageSenderId == otherParticipantId &&
                    chatRoom.lastMessageData['status'] == 'sent' &&
                    chatRoom.lastMessageData['receiverId'] == currentUserId;

                return ListTile(
                  leading: GestureDetector(
                    onTap: () async {
                      if (user.profilePictureUrl.startsWith('http')) {
                        final imageProvider = NetworkImage(user.profilePictureUrl);
                        await precacheImage(imageProvider, context);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => showAtCenter(imagesUrl: user.profilePictureUrl),
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
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 66,
                        child: Text(
                          timestamp,
                          style: theme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isNewMessage)
                        Icon(Icons.circle_rounded, color: Colors.green, size: 16),
                    ],
                  ),
                  onTap: () async {
                    Provider.of<chatProvider>(context, listen: false)
                        .navigateToChat(context, user);
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
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('AllChats: dispose called. Cancelling subscription and closing Hive box.');
    _chatRoomsSubscription?.cancel();
    _userBox.close();
    super.dispose();
  }

  String formatTimeOrDate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays < 1 && now.day == time.day) {
      return DateFormat('hh:mm a').format(time);
    } else if (difference.inDays == 1 && now.day != time.day) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('dd MMM').format(time);
    }
  }
}
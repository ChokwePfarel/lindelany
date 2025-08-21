import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart' show Hive, Box;
import 'package:intl/intl.dart';
import 'package:lindelany/Constants/Constants.dart';
import 'package:provider/provider.dart';

import '../../Providers/chatProvider.dart';
import '../../classes/chatRoomModel.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
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
  bool get wantKeepAlive => true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatServices _chatServices = ChatServices();
  late Box<UserModel> _userBox;

  Map<String, UserModel> _allUsersMap = {};

  // New Future variable to hold the initialization task
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('AllChats: initState called.');
    // Initialize the future here to be used by FutureBuilder
    _initializationFuture = _initializeHiveBox();
  }

  // New method to handle initial Hive box opening
  Future<void> _initializeHiveBox() async {
    debugPrint('AllChats: _initializeHiveBox called.');
    try {
      _userBox = await Hive.openBox<UserModel>('user_data').timeout(const Duration(seconds: 10));
      final cachedUsers = _userBox.toMap().cast<String, UserModel>();
      setState(() {
        _allUsersMap = cachedUsers;
      });
      debugPrint('AllChats: Cached users loaded. Count: ${_allUsersMap.length}');
    } catch (e) {
      debugPrint("AllChats: Hive box open failed/timed out: $e");
      // Re-throw the error to be caught by FutureBuilder
      rethrow;
    }
  }

  Future<void> _refreshChats() async {
    debugPrint('AllChats: _refreshChats called.');
    // Clear cached users to force a fresh fetch
    setState(() {
      _allUsersMap.clear();
    });
    // The StreamBuilder will handle the re-fetch automatically since we clear the map
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint('AllChats: build called.');

    SizeConfig.init(context);
    final theme = Theme.of(context).textTheme;
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      debugPrint('AllChats: Building with no current user.');
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
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshChats();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Text('Refresh Chats'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('AllChats: FutureBuilder waiting for initialization.');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('AllChats: FutureBuilder error: ${snapshot.error}');
            return Center(child: Text('Error initializing chats: ${snapshot.error}'));
          }

          // Once the Future is complete, we build the StreamBuilder
          return RefreshIndicator(
            onRefresh: _refreshChats,
            child: StreamBuilder<List<ChatRoomModel>>(
              stream: _chatServices.getChatRoomsStream(currentUserId),
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

                // Fetch missing users logic remains inside the listener implicitly
                // The StreamBuilder will handle updates as new users are fetched
                _fetchMissingUsers(chatRooms, currentUserId);

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
                            width: SizeConfig.screenWidth * 0.18,
                            child: Text(
                              timestamp,
                              style: theme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          buildMessageStatus(chatRoom, currentUserId)
                        ],
                      ),
                      onTap: () async {
                        Provider.of<chatProvider>(context, listen: false)
                            .navigateToChat(context, user);
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Refactored method to handle fetching missing users
  void _fetchMissingUsers(List<ChatRoomModel> chatRooms, String currentUserId) async {
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
      final fetchedUsers = <UserModel>[];
      for (final userId in userIdsToFetch) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
          if (userDoc.exists) {
            final user = UserModel.fromDocument(userDoc);
            fetchedUsers.add(user);
            await _userBox.put(userId, user);
          }
        } catch (e) {
          debugPrint("AllChats: Error fetching user $userId: $e");
        }
      }
      if (fetchedUsers.isNotEmpty) {
        if (mounted) {
          setState(() {
            for (final user in fetchedUsers) {
              _allUsersMap[user.userId] = user;
            }
            debugPrint('AllChats: Updated _allUsersMap with ${fetchedUsers.length} new users.');
          });
        }
      }
    }
  }

  Widget buildMessageStatus(ChatRoomModel chatRoom, String currentUserId) {
    final isReceived = chatRoom.lastMessageSenderId != currentUserId;
    final status = chatRoom.lastMessageData['status'];

    if (isReceived) {
      if (status != 'read') {
        return Icon(Icons.circle, color: blue900, size: 10);
      } else {
        return const SizedBox();
      }
    } else {
      return Text(status ?? '', style: const TextStyle(fontSize: 12));
    }
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

  @override
  void dispose() {
    debugPrint('AllChats: dispose called. Closing Hive box.');
    _userBox.close();
    super.dispose();
  }
}

//SHOW DATA FROM SEVER, AND HIVE LATER
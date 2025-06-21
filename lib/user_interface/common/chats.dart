import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lindelany/methods_Funtions/check_netwok.dart';
import 'package:provider/provider.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/chatRoomModel.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/chatService.dart';
import '../../utility/utility_class.dart';
import '../landlord/show_atCenter.dart';

class AllChats extends StatefulWidget {
  // Add a field to receive notification data
  final Map<String, dynamic>? notificationData;

  const AllChats({Key? key, this.notificationData}) : super(key: key);

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatServices _chatServices = ChatServices(); // Use a private variable

  // This stream should now fetch ChatRoomModel, not UserModel directly for the list
  late Stream<List<ChatRoomModel>> _chatRoomsStream;
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

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      // Initialize the stream to get chat rooms for the current user
      _chatRoomsStream = _chatServices.getChatRoomsStream(currentUserId);
    } else {
      // Handle case where user is not logged in (e.g., return empty stream)
      _chatRoomsStream = Stream.value([]);
      debugPrint("AllChats: No current user logged in, cannot fetch chat rooms.");
    }

    // Preload all users for quick lookup later
    _fetchAllUsersOnce();

    // Check for notification data when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialNotificationData();
    });
  }

  Future<void> _fetchAllUsersOnce() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        _allUsersMap = {
          for (var doc in snapshot.docs) doc.id: UserModel.fromDocument(doc)
        };
      });
      debugPrint("AllChats: Fetched ${_allUsersMap.length} users.");
    } catch (e) {
      debugPrint("AllChats: Error fetching all users: $e");
    }
  }


  // New method to handle incoming notification data for navigation
  void _handleInitialNotificationData() {
    if (widget.notificationData != null) {
      debugPrint('AllChats: Received notification data: ${widget.notificationData}');
      // Extract necessary info from notificationData
      final String? senderId = widget.notificationData!['senderId'];
      // The 'chatRoomId' would also be very useful if passed in payload
      final String? chatRoomIdFromNotification = widget.notificationData!['chatRoomId'];


      if (senderId != null) {
        // Find the UserModel of the sender from our preloaded map
        final senderUser = _allUsersMap[senderId];

        if (senderUser != null) {
          debugPrint('AllChats: Navigating to chat with ${senderUser.userName} from notification.');
          // Use Provider to navigate to the specific chat screen
          Provider.of<chatProvider>(context, listen: false).navigateToChat(context, senderUser);
        } else {
          debugPrint('AllChats: Sender user not found in local map: $senderId');
          // Fallback: If user not found, might need to fetch it or navigate to a default screen
        }
      } else {
        debugPrint('AllChats: Notification senderId is null.');
      }
    }
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
          chatRooms.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];

              // Determine the other participant's ID
              final otherParticipantId = chatRoom.participants.firstWhere(
                    (id) => id != currentUserId,
                orElse: () => '', // Fallback if somehow only current user is participant
              );

              // Get the UserModel for the other participant
              final user = _allUsersMap[otherParticipantId];

              // If for some reason the other user's data isn't available, skip or show placeholder
              if (user == null) {
                debugPrint("AllChats: User data not found for ID: $otherParticipantId");
                return const SizedBox.shrink(); // Hide this chat room if user data is missing
              }

              final timestamp = formatTimeOrDate(chatRoom.lastMessageTimestamp);
              final String displayMessage = chatRoom.lastMessageData['type'] == 'image'
                  ? 'Sent an image' // Or an icon, etc.
                  : (chatRoom.lastMessage.length > 21
                  ? '${chatRoom.lastMessage.substring(0, 21)}...'
                  : chatRoom.lastMessage);

              // Check if the last message was sent by the other user and is not yet read by current user
              final bool isNewMessage = chatRoom.lastMessageSenderId == otherParticipantId &&
                  chatRoom.lastMessageData['status'] == 'sent' &&
                  chatRoom.lastMessageData['receiverId'] == currentUserId;


              return ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    // Preload image before navigation
                    if (user.profilePictureUrl.startsWith('http')) {
                      final imageProvider = NetworkImage(user.profilePictureUrl);
                      await precacheImage(imageProvider, context);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => showAtCenter(
                          imagesUrl: user.profilePictureUrl, // Pass actual URL
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: user.profilePictureUrl.startsWith('http')
                        ? CachedNetworkImageProvider(user.profilePictureUrl)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    radius: 25,
                  ),
                ),
                title: Text(
                  user.userName,
                  style: theme.bodyMedium?.copyWith(color: Colors.black,fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      displayMessage,
                      style: theme.bodySmall?.copyWith(
                        color: isNewMessage ? Colors.black : Colors.grey, // Bold/darker for new messages
                        fontWeight: isNewMessage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 63,
                        child: Text(
                        timestamp, style: theme.bodySmall?.copyWith(color: Colors.grey,fontSize: 14))),
                    if (isNewMessage)
                      Icon(
                        Icons.circle, // Dot for unread
                        color: Colors.blue.shade900,
                        size: 16,
                      )
                    else // For read messages or messages sent by current user
                      Icon(
                        Icons.check_circle_rounded, // Delivered/Read icon
                        color: Colors.blue.shade900,
                        size: 16,// Or a different color for read
                      ),
                  ],
                ),
                onTap: () {
                  // Navigate to chat and ensure messages are marked as read
                  // The Chatpage itself will mark messages as read in its initState
                  Provider.of<chatProvider>(context, listen: false)
                      .navigateToChat(context, user);
                },
              );
            },
          );
        },
      ),
    );
  }
}
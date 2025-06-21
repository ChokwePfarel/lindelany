import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/message_model.dart';
import '../../classes/student_model.dart';
import '../../classes/user_model.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/customInput.dart';
import '../../custom_made/widgets/custom_chat_UI.dart';
import '../../firebase_Set/setStudent.dart';
import '../../firebase_Set/user.dart';
import '../../methods_Funtions/chatService.dart';
import '../../providers/otherUser_id_set.dart';
import '../../utility/utility_class.dart';
import 'Accommodations.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({
    super.key,
  });

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _messageController = TextEditingController();
  // Fixed typo: _chatServieces -> _chatServices
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<List<StudentModel>> _studentsFuture; // Preloaded students list

  ScrollController _scrollController = ScrollController();


  // Variables to hold the chat room ID and the other user's model
  late String _chatRoomId;
  late UserModel _otherUser;

  @override
  void initState() {
    super.initState();

    // You can scroll when new messages arrive
    _scrollToBottom();
    // Use addPostFrameCallback to ensure context is fully available after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access providers safely here
      final chatProviderr = Provider.of<chatProvider>(context, listen: false);
      _otherUser = chatProviderr.selectedUser; // Get the selected user from provider

      final currentUserId = _auth.currentUser!.uid;

      // Calculate chatRoomId consistently
      List<String> participants = [currentUserId, _otherUser.userId];
      participants.sort(); // Sort to ensure consistent ID (e.g., user1_user2 vs user2_user1)
      _chatRoomId = participants.join('_');

      // Now call _markMessagesAsRead with the correct chatRoomId and user IDs
      _markMessagesAsRead(currentUserId, _otherUser.userId);
    });

    // Keep your existing Future for students if still required
    _studentsFuture = StudentProvider().studentsStream.first;
  }

  // Updated _markMessagesAsRead to use ChatServices
  void _markMessagesAsRead( String currentUserId, String otherUserId) async {
    try {
      await _chatServices.markMessagesAsRead(currentUserId, otherUserId);
      debugPrint('Messages in chat room $_chatRoomId marked as read.');
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Renamed 'send' to '_sendMessage' for consistency with private methods
  void _sendMessage() async {
    String currentUserId = _auth.currentUser!.uid;
    String textMessage = _messageController.text.trim();

    // Ensure we have a valid recipient and a non-empty message
    if (textMessage.isNotEmpty && _otherUser.userId != currentUserId) {
      _messageController.clear(); // Clear input field immediately
      FocusScope.of(context).unfocus(); // Dismiss keyboard

      try {
        // Corrected sendMessage call: now requires receiverId, message, and chatRoomId
        await _chatServices.sendMessage(_otherUser.userId, textMessage, _chatRoomId);
        debugPrint('Message sent or queued successfully to $_chatRoomId');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent")),
        );
      } catch (e) {
        debugPrint('Error from _sendMessage function: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: ${e.toString()}")),
        );
      }
    } else if (textMessage.isEmpty) {
      debugPrint("Attempted to send an empty message.");
    } else if (_otherUser.userId == currentUserId) {
      debugPrint("Attempted to send message to self (not allowed by current logic).");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot send message to yourself")),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access provider in build method to ensure it's always up-to-date
    final chatProviderr = Provider.of<chatProvider>(context);
    _otherUser = chatProviderr.selectedUser; // Keep _otherUser updated

    final theme = Theme.of(context).textTheme;

    final currentUserProvider = Provider.of<UserProvider>(context).user;
    bool isStudent = currentUserProvider!.userType.toLowerCase() == 'student';
    // Use _otherUser for the landlord check
    bool isLandlord = _otherUser.userType.toLowerCase() == 'landlord';

    bool both = isStudent && isLandlord; // True if current user is student and other user is landlord

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: blue900,
          leading: Padding(
            padding: const EdgeInsets.all(5),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: _otherUser.profilePictureUrl.startsWith('http')
                  ? CachedNetworkImageProvider(_otherUser.profilePictureUrl)
                  : AssetImage(_otherUser.profilePictureUrl) as ImageProvider, // Cast for AssetImage
            ),
          ),
          title: Text(
            _otherUser.userName, // Display the other user's name
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis, // Prevents text overflow
          ),
          actions: [
            if (both)
              IconButton(
                onPressed: () {
                  Provider.of<setID>(context, listen: false)
                      .setUserId(_otherUser.userId); // Use _otherUser.userId

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Accomodations()),
                  );
                },
                icon: const Icon(Icons.house_rounded, color: Colors.white),
              ),
            if (!both) boxx,
          ],
        ),
        body: FutureBuilder(
          future: _studentsFuture, // This is your existing FutureBuilder
          builder: (context, snapshot) {
            if (AsyncUtils.isLoadingOrError(snapshot)) {
              return AsyncUtils.BuildIsloadingOrError(snapshot);
            }

            final students = snapshot.data!;
            // Find the student who matches the chat recipient (_otherUser)
            final chatStudent = students.firstWhere(
                  (studentt) => studentt.userId == _otherUser.userId,
              orElse: () => StudentModel(
                userId: _otherUser.userId, // Default StudentModel for the other user
                province: 'Student/', // Placeholder values
                uni: '',
                year: '',
                payment: '',
              ),
            );

            return Padding(
              padding: paddingg,
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  if (currentUserProvider.userType.toLowerCase() != 'student')
                    customCard1(
                      colorr: Colors.blue,
                      widgett: Text(
                        '${_otherUser.userName} is a ${chatStudent.year} '
                            'year student at ${chatStudent.uni}. ${_otherUser.userName} is from ${chatStudent.province}.'
                            'Payment mode:${chatStudent.payment}. Gender: ${_otherUser.userGender}',
                        style: theme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox(), // Use const for SizedBox

                  const SizedBox(height: 30),

                  Expanded(
                    child: StreamBuilder<List<MessageModel>>(
                      // CRITICAL: Now pass the calculated _chatRoomId to getMessages
                      stream: _chatServices.getMessages(_chatRoomId),
                      builder: (context, snapshot) {
                        if (AsyncUtils.isLoadingOrError(snapshot)) {
                          return AsyncUtils.BuildIsloadingOrError(snapshot);
                        }

                        final messages = snapshot.data!;
                        // If no messages, show a friendly prompt
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text('Start chatting!', style: TextStyle(color: Colors.white70)),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: false,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: messages.length,
                          // Pass messages in reverse order for newest at bottom display
                          itemBuilder: (context, index) {
                            return CustomMessage(messages[index]);
                          },
                        );
                      },
                    ),
                  ),

                  /// Input field and send button
                  Row(
                    children: [
                      Expanded(
                        child: Custominput(
                          Controller: _messageController,
                          HintText: 'Message',
                          circular: 40,
                          isPadding: true,
                          enabled: false,
                          onChange: (String ) {  },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: blue900,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendMessage, // Call the corrected _sendMessage method
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

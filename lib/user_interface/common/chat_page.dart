
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' as Network;
import 'package:flutter/material.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/transport_broadcast/broadcast_vehicle_model.dart';
import 'package:lindelany/user_interface/common/reference_listing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Constants/constants.dart';
import '../../Providers/chatProvider.dart';

import '../../custom_made/widgets/custom_chat_UI.dart';
import '../../firebase_Set/set_student.dart';
import '../../firebase_Set/user.dart';
import '../../methods_functions/chatService.dart';
import '../../models/message_model.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import '../../static/utils.dart';
import '../../transport_broadcast/from_firebase/transport.dart';
import '../landlord/show_atCenter.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;


  late Future<List<StudentModel>> _studentsFuture;
  late Future<List<vehicleModel>> _driverFuture;

  final ScrollController _scrollController = ScrollController();

  late String _chatRoomId;
  late UserModel _otherUser;


  @override
  void initState() {
    super.initState();
    _studentsFuture = StudentProvider().studentsStream.first;
    _driverFuture = CreateTransport().allVehicles.first;
  }


  void _markMessagesAsRead() async {
    final currentUserId = _auth.currentUser!.uid;
    if (_otherUser.userId != currentUserId) {
      await _chatServices.markMessagesAsRead(currentUserId, _otherUser.userId);
    }

    if (!mounted) return;
  }

  void _sendMessage() async {
    final currentUserId = _auth.currentUser!.uid;
    final textMessage = _messageController.text.trim();

    if (_chatRoomId.isEmpty || _otherUser.userId.isEmpty || !mounted) {
//      debugPrint("Missing chat data, cannot send.");
      return;
    }

    if (textMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message cannot be empty.")),
      );
      return;
    }

    if (_otherUser.userId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot message yourself.")),
      );
      return;
    }

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      await _chatServices.sendMessage(
        _otherUser.userId,
        textMessage,
        _chatRoomId,
      );
      _scrollToBottom();
    } catch (e) {
//      debugPrint("Failed to send: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> openDialpad(String phone) async {
    final Uri phoneNum = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneNum)) {
      await launchUrl(phoneNum);
    } else {
      throw 'Failed to launch dial pad with $phone';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final chatProviderr = Provider.of<chatProvider>(context);
    _otherUser = chatProviderr.selectedUser;

    final currentUserId = _auth.currentUser!.uid;
    final participants = [currentUserId, _otherUser.userId]..sort();
    _chatRoomId = participants.join('_');

    final currentUserProvider = Provider.of<UserProvider>(context).user!;
    final currentUserType = currentUserProvider.userType.toLowerCase();
    final isStudent = currentUserType == 'student';
    final currentUserIsLandlord = currentUserType == 'landlord';
    final isLandlord = _otherUser.userType.toLowerCase() == 'landlord';

    final showStudentDetail = isStudent && isLandlord;

    _markMessagesAsRead(); // Safe to call in build after variables are initialized

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: blue900,
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () async {
              final imageProvider =
              Network.NetworkImage(_otherUser.profilePictureUrl);
              await precacheImage(imageProvider, context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowAtCenter(
                    imagesUrl: _otherUser.profilePictureUrl,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: _otherUser.profilePictureUrl.startsWith('http')
                  ? CachedNetworkImageProvider(_otherUser.profilePictureUrl)
                  : AssetImage(_otherUser.profilePictureUrl)
              as ImageProvider<Object>,
            ),
          ),
        ),
        title: Text(
          _otherUser.userName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
          actions: [
            if (currentUserIsLandlord)
              IconButton(
                icon: const Icon(Icons.info, color: Colors.white),
                onPressed: () async {
                  await analytics.logEvent(name: 'view_student_Inf');
                  final chatStudent = await _studentsFuture;
                  _showUserDetailDialog(
                      context, _otherUser, chatStudent.first);
                },
              ),

            if (_otherUser.userType.toLowerCase() == 'transportation')
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () async {
                  try {
                    final vehicles = await _driverFuture;
                    final vehicle = vehicles.firstWhere(
                          (v) => v.userId == _otherUser.userId,
                      orElse: () => throw 'No vehicle profile found for this user',
                    );

                    if (vehicle.numbers.isNotEmpty) {
                      await openDialpad(vehicle.numbers);
                    } else {
                      throw 'No phone number found for this driver';
                    }
                  } catch (e) {
//                    debugPrint('Dial error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),

            if(isStudent && isLandlord)
              IconButton(icon: Icon(Icons.house,color: Colors.white,
              ), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReferenceListing(
                  landlordId: _otherUser.userId,
                )));
              },)

          ]

      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FutureBuilder<List<StudentModel>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (AsyncUtils.isLoadingOrError(snapshot)) {
              return AsyncUtils.BuildIsloadingOrError(snapshot);
            }

            final students = snapshot.data!;
            final chatStudent = students.firstWhere(
                  (s) => s.userId == _otherUser.userId,
              orElse: () => StudentModel(
                userId: '', province: '', uni: '', year: '', payment: '',
              ),
            );

            return Column(
              children: [
                const SizedBox(height: 6),
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: _chatServices.getMessages(_chatRoomId),
                    builder: (context, snapshot) {
                      if (AsyncUtils.isLoadingOrError(snapshot)) {
                        return AsyncUtils.BuildIsloadingOrError(snapshot);
                      }

                      final messages = snapshot.data!;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'Start chatting!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (_, index) =>
                            CustomMessage(messages[index], _chatRoomId),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: paddingg.left,
                    right: paddingg.right,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.screenHeight * 0.010,
                            horizontal: SizeConfig.screenWidth * 0.020,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Message',
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: blue900,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showUserDetailDialog(
      BuildContext context, UserModel otherUser, StudentModel student) {
    final theme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: blue900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${otherUser.userName} is a ${student.year} year student at ${student.uni}.',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'From ${student.province}',
                        style: theme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Payment method: ${student.payment}',
                        style: theme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Gender: ${otherUser.userGender}',
                        style: theme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: blue900, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

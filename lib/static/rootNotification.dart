import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lindelany/methods_Funtions/chatService.dart';
import 'dart:async';
import '../classes/chat_room_model.dart';
import '../firebase_Set/set_student.dart';
import '../firebase_Set/user.dart';
import '../providers/deepLinkProvider.dart';
import '../providers/notification_bell.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// Import your screens
// import 'package:lindelany/screens/payment_status_screen.dart'; // Uncomment if you have this

class RootNotificationHandler extends StatefulWidget {
  final Widget child;

  const RootNotificationHandler({super.key, required this.child});

  @override
  State<RootNotificationHandler> createState() => _RootNotificationHandlerState();
}

class _RootNotificationHandlerState extends State<RootNotificationHandler> {
  StreamSubscription<bool>? _unreadMessagesSubscription;
  final ChatServices _chatService = ChatServices();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).currentStudent();
        Provider.of<UserProvider>(context, listen: false).fetchUser();

        final deepLinkProvider = Provider.of<DeepLinkProvider>(
            context, listen: false);
        deepLinkProvider.initAppLinks();
      }
    });

    _setupUnreadMessagesListener();
    _startChatRoomStreamForUnreadChecks();
    _foregroundHandle();
    _localNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate based on message content
    });
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void _localNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  void _foregroundHandle() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show notification
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['action'] == 'open_subscription_page') {
        // Navigate to subscription page
      }
    });
  }

  void _setupUnreadMessagesListener() {
    if (mounted) {
      _unreadMessagesSubscription =
          _chatService.unreadMessagesStream.listen((hasUnread) {
            if (mounted) {
              context.read<NotificationProvider>().setNewMessages(hasUnread);
              debugPrint(
                  'RootNotificationHandler: Unread messages status updated: $hasUnread');
            }
          });
    }
  }

  StreamSubscription<List<ChatRoomModel>>? _chatRoomsStreamSubscription;

  void _startChatRoomStreamForUnreadChecks() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _chatRoomsStreamSubscription =
          _chatService.getChatRoomsStream(currentUserId).listen(
                  (chatRooms) {
                debugPrint(
                    'RootNotificationHandler: Chat rooms stream updated. Triggering unread check.');
              },
              onError: (error) {
                debugPrint(
                    'RootNotificationHandler: Error listening to chat rooms stream: $error');
              }
          );
    } else {
      debugPrint(
          'RootNotificationHandler: No current user ID, cannot start chat rooms stream for unread checks.');
    }
  }

  @override
  void dispose() {
    _unreadMessagesSubscription?.cancel();
    _chatRoomsStreamSubscription?.cancel();
    super.dispose();
  }

  void _handleDeepLink(BuildContext context, Uri uri, DeepLinkProvider deepLinkProvider) {
//    debugPrint('🔗 RootNotificationHandler: Processing deep link: ${uri.toString()}');
//    debugPrint('🔗 Scheme: ${uri.scheme}');
//    debugPrint('🔗 Host: ${uri.host}');
//    debugPrint('🔗 Path: ${uri.path}');
//    debugPrint('🔗 Query params: ${uri.queryParameters}');}
   }


  @override
  Widget build(BuildContext context) {
    return Consumer<DeepLinkProvider>(
      builder: (context, deepLinkProvider, child) {
        final uri = deepLinkProvider.pendingDeepLinkUri;

        if (uri != null) {
          // Use addPostFrameCallback to ensure navigation happens after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _handleDeepLink(context, uri, deepLinkProvider);
            }
          });
        }

        return child ?? const SizedBox.shrink();
      },
      child: widget.child,
    );
  }
}

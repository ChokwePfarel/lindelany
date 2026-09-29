import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/constants/globals.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../firebase_Set/set_student.dart';
import '../firebase_Set/user.dart';
import '../methods_functions/chatService.dart';
import '../models/chat_room_model.dart';
import '../providers/deepLinkProvider.dart';
import '../providers/notification_bell.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../signIn&out/resetPassword.dart';

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

        final deepLinkProvider = Provider.of<DeepLinkProvider>(context, listen: false);
        deepLinkProvider.initAppLinks();
      }
    });

    _setupUnreadMessagesListener();
    _startChatRoomStreamForUnreadChecks();
    _foregroundHandle();
    _localNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate based on message content if needed
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
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
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
        // Handle foreground notifications
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
      _unreadMessagesSubscription = _chatService.unreadMessagesStream.listen((hasUnread) {
        if (mounted) {
          context.read<NotificationProvider>().setNewMessages(hasUnread);
          debugPrint('RootNotificationHandler: Unread messages status updated: $hasUnread');
        }
      });
    }
  }

  StreamSubscription<List<ChatRoomModel>>? _chatRoomsStreamSubscription;

  void _startChatRoomStreamForUnreadChecks() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _chatRoomsStreamSubscription = _chatService.getChatRoomsStream(currentUserId).listen((chatRooms) {
        debugPrint('RootNotificationHandler: Chat rooms stream updated. Triggering unread check.');
      }, onError: (error) {
        debugPrint('RootNotificationHandler: Error listening to chat rooms stream: $error');
      });
    }
  }

  @override
  void dispose() {
    _unreadMessagesSubscription?.cancel();
    _chatRoomsStreamSubscription?.cancel();
    super.dispose();
  }

  void _handleDeepLink(Uri uri, DeepLinkProvider deepLinkProvider) {
    debugPrint('🔗 RootNotificationHandler: Processing deep link: ${uri.toString()}');

    // Check if the path points to reset-password
    if (uri.path.contains('reset-password')) {
      final String? mode = uri.queryParameters['mode'];
      final String? oobCode = uri.queryParameters['oobCode'];

      if (mode == 'resetPassword' && oobCode != null) {
        debugPrint('✅ Valid reset password link found. Navigating to ResetPasswordPage.');

        // 1. Clear the pending link IMMEDIATELY to avoid duplicate triggers during rebuilds
        deepLinkProvider.clearPendingDeepLink();

        // 2. Use the Global Navigator Key to push the route
        // This is necessary because RootNotificationHandler context is often above the Navigator
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(oobCode: oobCode),
          ),
        );
      } else {
        debugPrint('⚠️ Link contains reset-password but missing mode or oobCode. Clearing link.');
        deepLinkProvider.clearPendingDeepLink();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeepLinkProvider>(
      builder: (context, deepLinkProvider, child) {
        final uri = deepLinkProvider.pendingDeepLinkUri;

        if (uri != null) {
          // Schedule navigation for after the frame to ensure Navigator is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _handleDeepLink(uri, deepLinkProvider);
            }
          });
        }

        return child ?? const SizedBox.shrink();
      },
      child: widget.child,
    );
  }
}

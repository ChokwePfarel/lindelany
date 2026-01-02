
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/classes/user_model.dart';
import 'package:lindelany/providers/deepLinkProvider.dart';
import 'package:lindelany/providers/check_connection.dart';
import 'package:lindelany/providers/has_newMessage.dart';
import 'package:lindelany/providers/notification_bell.dart';
import 'package:lindelany/signIn&out/gate.dart';
import 'package:lindelany/static/rootNotification.dart';
import 'package:lindelany/transport_broadcast/from_firebase/transport.dart';
import 'package:provider/provider.dart';
import 'Providers/chatProvider.dart';
import 'firebase_Set/set_student.dart';
import 'firebase_Set/user.dart';
import 'firebase_options.dart';
import 'methods_Funtions/ImageUpload.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';


/// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  await Firebase.initializeApp();

////   print(' Background message received: ${message.messageId}');
////   print('Title: ${message.notification?.title}');
////   print('Body: ${message.notification?.body}');

  // Optional: Show a local notification for background messages
  if (message.notification != null) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: jsonEncode(message.data), // attach payload for clicks
    );
  }
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Hive.registerAdapter(UserModelAdapter());

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();

  // Init local notifications (foreground display)
  const AndroidInitializationSettings initAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: initAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  //analtics

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  // Initialize App Check

  await FirebaseAppCheck.instance.activate(
    // For Android, use Play Integrity
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    // For iOS, use App Attest
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.appAttest,
    // For web (if you have a web version)
    webProvider: kDebugMode
        ? ReCaptchaV3Provider('your-recaptcha-site-key')
        : ReCaptchaV3Provider('your-recaptcha-site-key'),
  );



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => chatProvider()),
        //ChangeNotifierProvider(create: (_) => setID()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => CreateTransport()),
        ChangeNotifierProvider(create: (context) => NetworkStatusProvider()),
        ChangeNotifierProvider(create: (context) => CreateTransport()),
        ChangeNotifierProvider(create: (context) => HasNewMessage()),
        ChangeNotifierProvider(create: (context) => DeepLinkProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadMethod()),
      ],
      child: RootNotificationHandler(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          navigatorObservers: [observer], // <-- attach observer here
          theme: ThemeData(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: 20),
              bodyMedium: TextStyle(fontSize: 17),
              bodySmall: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),

          home: const SplashScreen(),
        ),
      ),
    ),
  );
}

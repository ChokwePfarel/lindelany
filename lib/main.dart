import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lindelany/constants/globals.dart';
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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

import 'methods_functions/ImageUpload.dart';
import 'models/user_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

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
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformDetails,
      payload: jsonEncode(message.data), 
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Restored based on your package requirements
  await GoogleSignIn.instance.initialize(
    serverClientId: '423113472279-vk173aachkhf3dch5d8hn18u3u11dfta.apps.googleusercontent.com',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Hive.registerAdapter(UserModelAdapter());

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await FirebaseMessaging.instance.requestPermission();

  const AndroidInitializationSettings initAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: initAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
  );

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
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
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => CreateTransport()),
        ChangeNotifierProvider(create: (context) => NetworkStatusProvider()),
        ChangeNotifierProvider(create: (context) => HasNewMessage()),
        ChangeNotifierProvider(create: (context) => DeepLinkProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadMethod()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(fontSize: 17),
            bodySmall: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        builder: (context, child) {
          return RootNotificationHandler(child: child!);
        },
        home: const SplashScreen(),
      ),
    ),
  );
}

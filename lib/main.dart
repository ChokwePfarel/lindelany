import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lindelany/classes/user_model.dart';
import 'package:lindelany/providers/check_connection.dart';
import 'package:lindelany/providers/has_newMessage.dart';
import 'package:lindelany/providers/notification_bell.dart';
import 'package:lindelany/providers/otherUser_id_set.dart';
import 'package:lindelany/signIn&out/Gate.dart';
import 'package:lindelany/transport_broadcast/from_firebase/transport.dart';
import 'package:provider/provider.dart';
import 'Providers/chatProvider.dart';
import 'firebase_Set/setStudent.dart';
import 'firebase_Set/user.dart';
import 'firebase_options.dart';
import 'methods_Funtions/ImageUpload.dart';
import 'package:hive_flutter/hive_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Hive.registerAdapter(UserModelAdapter());






  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => chatProvider()),
        ChangeNotifierProvider(create: (_) => setID()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => NetworkStatusProvider()),
        ChangeNotifierProvider(create: (context) => CreateTransport()),
        ChangeNotifierProvider(create: (context) => HasNewMessage()),
        ChangeNotifierProvider(create: (_) => ImageUploadMethod()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(fontSize: 17),
            bodySmall: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),

        home: const splashScreen(),
      ),
    ),
  );
}

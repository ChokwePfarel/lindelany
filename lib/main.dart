import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/providers/notification_bell.dart';
import 'package:lindelany/providers/otherUser_id_set.dart';
import 'package:lindelany/signIn&out/Gate.dart';
import 'package:provider/provider.dart';
import 'Providers/chatProvider.dart';
import 'firebase_Set/setStudent.dart';
import 'firebase_Set/user.dart';
import 'firebase_options.dart';
import 'methods_Funtions/ImageUpload.dart';
import 'methods_Funtions/Navigation.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        //UserProvider..fetcuser is calling user too early in a case where a user isn't logged in yet
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => chatProvider()),
        ChangeNotifierProvider(create: (_) => setID()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),

        //ChangeNotifierProvider(create: (_) => HasNewMessage()),
        ChangeNotifierProvider(create: (_) => ImageUploadMethod()),

        FutureProvider<bool>(
          create: (context) => CustomNavigation().getDocumentBool('Vehicle'),
          initialData: false,
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
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

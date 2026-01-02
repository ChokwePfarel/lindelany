import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckService {
  static Future<void> initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.appAttest,
      );

      if (kDebugMode) {
////         print('App Check initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
////         print('Failed to initialize App Check: $e');
      }
      // In production, you might want to handle this differently
      // Don't throw the error as it might prevent app startup
    }
  }

  // Get App Check token manually if needed
  static Future<String?> getAppCheckToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
////         print('Failed to get App Check token: $e');
      }
      return null;
    }
  }

  // Listen to token changes
  static void listenToTokenChanges() {
    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      if (kDebugMode) {
////         print('App Check token changed: ${token?.substring(0, 20)}...');
      }
    });
  }
}

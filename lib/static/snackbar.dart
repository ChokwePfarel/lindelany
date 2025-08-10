import 'package:flutter/material.dart';
import 'package:lindelany/Constants/Constants.dart';
import 'package:lindelany/constants/scale.dart';

import '../signIn&out/Auth.dart';
import '../signIn&out/logIn.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry margin = const EdgeInsets.all(16),
  }) {
    final snackBar = SnackBar(
      duration: (const Duration(seconds: 4)),
      content: Text(message, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      behavior: behavior,
      margin: margin,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

//--------------------------------------------------------------------------
//Dialog
//--------------------------------------------------------------------------

class CustomDialog {
  static void showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevents dismissing by tapping outside
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontWeight: FontWeight.bold, color: blue900),
            ),
          ],
        ),
      ),
    );
  }
}

class LoggingOut {
  static void showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Are you sure you want to Log out?',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        backgroundColor: Colors.white,
        content: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No', style: TextStyle(color: blue900,fontWeight: FontWeight.bold,fontSize: 20)),
            ),

            SizedBox(width: SizeConfig.screenWidth * 0.030),

            TextButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              child: Text('Yes', style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

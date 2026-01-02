import 'package:flutter/material.dart';
import 'package:lindelany/Constants/constants.dart';
import 'package:lindelany/constants/scale.dart';

import '../signIn&out/authService.dart';
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

class CustomDialog {
  static void showLoading(BuildContext context, String message) {
    SizeConfig.init(context);

    showDialog(
      context: context,
      barrierDismissible: false, // prevents dismissing by tapping outside
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: blue900),
            SizedBox(height: SizeConfig.screenHeight * 0.016),
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

class confirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const confirmDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key); //This ensures the parent class is properly initialized
  // before class body runs.

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'No',
            style: TextStyle(
              color: blue900,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),

        TextButton(
          onPressed: () async {
            onConfirm;
          },
          child: Text(
            'Yes',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}



class LoggingOut {
  static void showLogout(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        content: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: blue900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSnackbarr {
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class AppSnackbar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}


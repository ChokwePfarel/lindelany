import 'package:flutter/material.dart';
import 'package:lindelany/Constants/Constants.dart';

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
      content: Text(
        message,
        style: TextStyle(color: textColor,),
      ),
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
            Text(message,style: TextStyle(fontWeight: FontWeight.bold,color: blue900),),
          ],
        ),
      ),
    );
  }
}

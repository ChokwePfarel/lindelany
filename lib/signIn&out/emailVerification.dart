/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Constants/Constants.dart';
import 'package:lindelany/static/snackbar.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //----------------------------------------------------------------------Resend

  bool _resending = false;

  Future<void> _resendEmail() async {
    try {
      setState(() => _resending = true);
      await _auth.currentUser!.sendEmailVerification();

      if (mounted) {
        CustomSnackbar.show(context, 'Email Sent');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, 'Failed, try again later');
      }
      print(e.toString());
    } finally {
      setState(() => _resending = false);
    }
  }

  //-----------------------------------------------------------------------Timer

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: blue900,

      body: Card(
        color: Colors.white,
        child: Column(
          children: [
            //ICON
            Text('Verify Your Email', style: theme.bodyLarge),

            Text(
              'Check Your Emails For A Verification Link and Click',
              style: theme.bodyMedium,
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: blue900),
              onPressed: () {
                _resending ? null : _resendEmail;
              },
              child: _resending
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Resend Email',
                      style: theme.bodyMedium!.copyWith(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lindelany/user_interface/common/onboarding.dart';

import '../Constants/Constants.dart';
import '../Transport_Broadcast/userInteface/all_broadcasts.dart';
import '../create_edit/student/create_student.dart';
import '../firebase_Set/user.dart';
import '../user_interface/landlord/my_listing.dart';
import 'gate.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final ValueNotifier<bool> isSigningIn = ValueNotifier(false);

  bool _isSignedOut = false;

  bool get isSignedOut => _isSignedOut;



  Future<void> saveFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final user = _auth.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
        {'fcmToken': token, 'dateCreated': Timestamp.now()},
      );

      debugPrint('AuthService: TOKEN UPDATED');
    }
  }

  //------------------------------------------------------------------------------
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await saveFcmToken();
      }

      return result.user;
    } catch (e) {
      debugPrint('AuthService: Sign-in error: $e');
      return null;
    }
  }

  //------------------------------------------------------------------------------
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String UserName,
    String userType,
    String userGender,
  ) async {
    try {
      debugPrint('AuthService: Creating user...');
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = result.user;

      if (user != null) {
        // CRITICAL: await document creation
        await UserProvider().createUser(
          user.uid,
          UserName,
          userType,
          userGender,
          '',
          true,
        );

        await saveFcmToken();
      }
      return user;
    } catch (e) {
      debugPrint('AuthService: Registration error: $e');
      return null;
    }
  }

  //-----------------------------------------------------------------------------

  Future<void> signInWithGoogle(BuildContext context, UserProvider userProvider) async {

    isSigningIn.value = true; // ← replaces showDialog

    debugPrint('🚩 AuthService: Google Sign-In started');

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      final GoogleSignInAccount account = await googleSignIn.authenticate();



      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user document exists
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.uid)
            .get();

        // If no document, create it
        if (!doc.exists) {
          debugPrint('🚩 New user: Creating document...');
          await UserProvider().createUser(
            firebaseUser.uid,
            account.displayName ?? '',
            '',
            '',
            account.photoUrl ?? '',
            true,
          );
        }

        // Ensure FCM token is saved
        await saveFcmToken();

        // After saveFcmToken()
        await userProvider.fetchUser(source: Source.server);

      }

      // The Gate widget will detect the new auth state and rebuild automatically.
    } catch (e) {
      debugPrint('🚩 Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-In failed: $e')),
        );
      }
    } finally {
      isSigningIn.value = false; // ← replaces Navigator.pop
    }
  }

  Future<void> _showRetryDialog(
    BuildContext context,
    String uid,
    GoogleSignInAccount account,
    String errorMessage,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Setup Failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'We couldn\'t complete your account setup. This might be due to a network issue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),

                // Error details (optional - for debugging)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: $errorMessage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Close dialog
                          Navigator.of(context).pop();

                          // Show loading indicator while signing out
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Sign out
                          await signOut();

                          if (context.mounted) {
                            Navigator.of(context).pop(); // Close loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signed out successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Retry Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Close retry dialog
                          Navigator.of(context).pop();

                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Retry user creation
                          try {
                            await UserProvider().createUser(
                              uid,
                              account.displayName ?? '',
                              '',
                              '',
                              account.photoUrl ?? '',
                              true,
                            );

                            // Verify creation
                            final verifyDoc = await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .get();

                            if (!context.mounted) return;
                            Navigator.of(context).pop(); // Close loading

                            if (verifyDoc.exists) {
                              // Success - Navigate to setup
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GoogleUserSetupPage(),
                                ),
                                (route) => false,
                              );
                            } else {
                              throw Exception(
                                'User document still missing after retry',
                              );
                            }
                          } catch (retryError) {
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Close loading

                              // Show error and let user try again
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Retry failed: $retryError'),
                                  backgroundColor: Colors.red,
                                  action: SnackBarAction(
                                    label: 'Retry',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Recursively show retry dialog again
                                      _showRetryDialog(
                                        context,
                                        uid,
                                        account,
                                        retryError.toString(),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: blue900,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //----------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn.instance.signOut();
      _isSignedOut = true;
    } catch (e) {
      debugPrint('AuthService: Error signing out: $e');
    }
  }

  //----------------------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Reset password error: ${e.code}');
    } catch (e) {
      debugPrint('AuthService: Unexpected reset error: $e');
    }
  }
}

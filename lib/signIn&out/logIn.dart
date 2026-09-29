import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/create_edit/student/create_student.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:lindelany/signIn&out/authService.dart';
import 'package:lindelany/signIn&out/gate.dart';
import '../Constants/Constants.dart';
import '../constants/scale.dart';
import '../custom_made/widgets/customInput.dart';
import '../firebase_Set/user.dart';
import '../methods_functions/check_netwok.dart';
import '../static/snackbar.dart';
import '../transport_broadcast/userInteface/all_broadcasts.dart';
import '../user_interface/landlord/my_listing.dart';
import 'newUser.dart';
import 'forgotPassword.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscured = true;

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  bool _isLoading = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      AuthService().saveFcmToken();

      // Fetch user data after successful login
      if (mounted) {
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).fetchUser(source: Source.server);

        await Provider.of<StudentProvider>(
          context,
          listen: false,
        ).currentStudent(source: Source.server);

        final user = Provider.of<UserProvider>(context, listen: false).user;

        final String? userType = user?.userType.toLowerCase();

        if (userType != null) {
          if (userType == 'landlord' && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyListing()),
            );
          } else if (userType == 'student' && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateStudentProfile(),
              ),
            );
          } else if (userType == 'transportation' && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AllBroadcast()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Gate()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        default:
          message = "Login failed: ${e.message}";
      }
      if (mounted) {
        CustomSnackbar.show(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    double hightTen = SizeConfig.heightUnit;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.052),
                SizedBox(height: screenHeight * 0.052),

                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: blue900,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'l',
                    style: GoogleFonts.signika(
                      color: Colors.white,
                      fontSize: 62,
                      fontWeight: FontWeight.bold,
                      height: 1, // prevent extra spacing
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.052),
                SizedBox(height: screenHeight * 0.052),

                CustomFormInput(
                  controller: _emailController,
                  labelText: "Email",
                  isObscured: false,
                  // Email shouldn't be obscured
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail,
                  // Changed from lock to mail icon for email
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    } else if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: hightTen),

                CustomFormInput(
                  controller: _passwordController,
                  labelText: "Password",
                  isObscured: _isObscured,
                  keyboardType: TextInputType.text,
                  prefixIcon: CupertinoIcons.lock,
                  isPassword: true,
                  onSuffixIconPressed: () {
                    _toggleObscureText();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                ),

                SizedBox(height: hightTen),

                ElevatedButton(
                  onPressed: () async {
                    final bool isConnected = await checkNetworkAndShowSnackbar(
                      context,
                    );
                    if (isConnected) {
                      if (!_isLoading) {
                        await _login();
                      }
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: blue900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20, // Adjust size as needed
                          height: 20, // Adjust size as needed
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0, // Makes the circle line thinner
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                SizedBox(height: hightTen),

                /*OutlinedButton(

                  onPressed:
                  () async{
                    await AuthService().signInWithGoogle(
                      context,
                      Provider.of<UserProvider>(context, listen: false),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Color(0xFFDADADA), width: 1),
                    shadowColor: Colors.black26,
                    padding: const EdgeInsets.all(0), // let the inner Row control padding
                  ),
                  child: Row(
                    children: [
                      // Google "G" sits in its own padded container — per brand guidelines
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/google-icon-logo-svgrepo-com.svg',
                          height: 18,
                          width: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Sign in with Google',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF3C4043),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 50), // balances the logo container width
                    ],
                  ),
                ),

                SizedBox(height: hightTen),*/

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blue900,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: blue900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

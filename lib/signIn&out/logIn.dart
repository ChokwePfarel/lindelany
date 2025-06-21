import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import '../Constants/Constants.dart';
import '../constants/scale.dart';
import '../custom_made/widgets/customInput.dart';
import '../firebase_Set/user.dart';
import '../user_interface/Common/Accommodations.dart';
import 'Auth.dart';
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
  final AuthService _authService = AuthService();

  bool _isObscured = true;
  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUser();
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Accomodations()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid credentials or user does not exist")),
        );
      }
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
                SizedBox(
                  height: screenHeight * 0.052,
                ),
                SizedBox(
                  height: screenHeight * 0.052,
                ),

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
                SizedBox(
                  height: screenHeight * 0.052,
                ),
                SizedBox(
                  height: screenHeight * 0.052,
                ),

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
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value.trim())) {
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
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: blue900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.nokora(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: hightTen),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegistrationPage()),
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
                          builder: (_) => const ForgotPasswordPage()),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:provider/provider.dart';
import '../Constants/constants.dart';
import '../Constants/lists.dart';
import '../constants/scale.dart';
import '../custom_made/widgets/customInput.dart';
import '../custom_made/widgets/custom_dropdown.dart';
import '../firebase_Set/user.dart';
import '../methods_Funtions/check_netwok.dart';
import 'authService.dart';
import 'logIn.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  final CollectionReference _firestore = FirebaseFirestore.instance.collection('StudentForm');

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  String _selectedGender = gender.first;
  String _selectedUserType = userType.first;

  bool _isLoading = false;

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim() ||
        _emailController.text.trim() != _confirmEmailController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords or Email do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
       User? user = await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _userNameController.text.trim(),
        _selectedUserType,
        _selectedGender,
      );

       if(user != null){

         if(_selectedUserType.trim().toLowerCase() == 'student'){
           await Provider.of<StudentProvider>(context, listen: false).createStudent(user.uid);

         }

         if (mounted) {
           CustomSnackbarr.show(context, 'Registration Successful', isSuccess: true);

           //await Provider.of<UserProvider>(context, listen: false).fetchUser();

           await Future.delayed(const Duration(milliseconds: 300));

           if (mounted) {
             Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (_) => const LoginPage()),
             );
           }
         }

       }

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        case 'weak-password':
          message = "Password too weak.";
          break;
        default:
          message = "Registration failed: ${e.message}";
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isObscured = true;

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    double hightTen = SizeConfig.heightUnit;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.104),
                SizedBox(height: screenHeight * 0.078),

                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: CustomDropdown(
                    value: _selectedUserType,
                    items: userType,
                    labelText: 'User Type',
                    onChanged: (newValue) {
                      _selectedUserType = newValue!;
                    },
                  ),
                ),
                SizedBox(height: hightTen),

                CustomFormInput(
                  controller: _emailController,
                  labelText: "Email",
                  isObscured: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail,
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
                  controller: _confirmEmailController,
                  labelText: "Confirm Email",
                  isObscured: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail,
                  validator: (value) {
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
                    } else if (value.length < 5) {
                      return 'Password too short';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Add at least one uppercase letter';
                    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Add at least one lowercase letter';
                    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Add at least one digit';
                    } else if (!RegExp(
                      r'[!@#$%^&*(),.?":{}|<>]',
                    ).hasMatch(value)) {
                      return 'Password must contain at least one special character';
                    }

                    return null;
                  },
                ),
                SizedBox(height: hightTen),

                CustomFormInput(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
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

                CustomFormInput(
                  controller: _userNameController,
                  labelText: "User Name",
                  isObscured: false,
                  // Email shouldn't be obscured
                  keyboardType: TextInputType.text,
                  prefixIcon: CupertinoIcons.mail,
                  // Changed from lock to mail icon for email
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'User name required';
                    } else if (value.length < 4) {
                      return 'User name should contain more than 4 letters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: hightTen),

                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: CustomDropdown(
                    value: _selectedGender,
                    items: gender,
                    labelText: 'Gender',
                    onChanged: (newValue) {
                      _selectedGender = newValue!;
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.052),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: blue900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  onPressed:() async {
                    final bool isConnected = await checkNetworkAndShowSnackbar(context);

                    if (isConnected) {
                      if (!_isLoading) {
                        await _register();
                      }
                    }
                  },
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
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                Row(
                  children: [
                    const Text("Already have an account ?"),
                    TextButton(
                      onPressed: () async {
                        final bool isConnected =
                            await checkNetworkAndShowSnackbar(context);
                        if (isConnected) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Invalid credentials or user does not exist",
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'sign In',
                        style: TextStyle(
                          color: blue900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
}

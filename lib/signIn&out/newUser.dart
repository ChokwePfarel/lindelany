import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lindelany/create_edit/student/create_student.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:lindelany/firebase_Set/user.dart';
import 'package:lindelany/signIn&out/gate.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/transport_broadcast/userInteface/all_broadcasts.dart';
import 'package:lindelany/user_interface/landlord/my_listing.dart';
import 'package:provider/provider.dart';
import '../Constants/constants.dart';
import '../Constants/lists.dart';
import '../constants/scale.dart';
import '../custom_made/widgets/customInput.dart';
import '../custom_made/widgets/custom_dropdown.dart';
import '../methods_functions/check_netwok.dart';
import 'authService.dart';
import 'logIn.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  /*final TextEditingController _confirmPasswordController =
  TextEditingController();*/
  final TextEditingController _userNameController = TextEditingController();

  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  String _selectedGender = gender.first;
  String _selectedUserType = userType.first;

  bool _isLoading = false;


  final Map<String, String> _universityDomains = {
    'University of the Western Cape (UWC)': '@myuwc.ac.za',
    'University of Cape Town (UCT)': '@myuct.ac.za',
    'Stellenbosch University': '@sun.ac.za',
    'University of the Witwatersrand': '@students.wits.ac.za',
    'University of Johannesburg': '@student.uj.ac.za',
    'University of Pretoria': '@tuks.co.za',
    'University of KwaZulu-Natal': '@stu.ukzn.ac.za',
    'Rhodes University': '@ru.ac.za',
    'Cape Peninsula University of Technology':'@mycput.ac.za'
  };


  Future<void> _register() async {
   // debugPrint('🚩 _register: Process Started');
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
     // debugPrint('🚩 _register: Validation Failed');
      return;
    }

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    try {
      //debugPrint('🚩 _register: Attempting Firebase Auth creation for ${_emailController.text.trim()}');
      User? user = await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _userNameController.text.trim(),
        _selectedUserType,
        _selectedGender,
      );

      if (user != null) {
       // debugPrint('🚩 _register: User created successfully. UID: ${user.uid}');

        if (_selectedUserType.trim().toLowerCase() == 'student') {
         // debugPrint('🚩 _register: User is student. Calling createStudent...');
          await studentProvider.createStudent(user.uid);
         // debugPrint('🚩 _register: studentProvider.createStudent completed');
        }

       // debugPrint('🔍 _register: Fetching user data to UserProvider...');
        await userProvider.fetchUser(source: Source.server);

        if (_selectedUserType.trim().toLowerCase() == 'student') {
          await studentProvider.currentStudent(source: Source.server);
        }

        if (mounted) {
          CustomSnackbar.show(context, 'Registration Successful');

          final appUser = userProvider.user;
          final String? type = appUser?.userType.toLowerCase();
         // debugPrint('🚩 _register: Deciding navigation for type: $type');

          Widget targetPage;
          if (type == 'landlord') {
           // debugPrint('🚩 _register: Navigating to MyListing');
            targetPage = const MyListing();
          } else if (type == 'student') {
           // debugPrint('🚩 _register: Navigating to CreateStudentProfile');
            targetPage = const CreateStudentProfile();
          } else if (type == 'transportation') {
            //debugPrint('🚩 _register: Navigating to AllBroadcast');
            targetPage = const AllBroadcast();
          } else {
           // debugPrint('🚩 _register: Unknown type or type is null. Navigating to Gate.');
            targetPage = const Gate();
          }

          //debugPrint('🚩 _register: Executing pushReplacement');
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => targetPage),
          );
        } else {
          //debugPrint('🚩 _register: Error - Widget unmounted before navigation could occur.');
        }
      } else {
        //debugPrint('🚩 _register: Error - AuthService returned null user. Check if Firestore creation failed.');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🚩 _register: FirebaseAuthException caught: ${e.code} - ${e.message}');
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
        CustomSnackbar.show(context, message);
      }
    } catch (e) {
      if (mounted) {
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                CustomDropdown(
                  value: _selectedUserType,
                  items: userType,
                  labelText: 'User Type',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUserType = newValue!;
                    });
                  },
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
                    }

                    final trimmedValue = value.trim().toLowerCase();

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(trimmedValue)) {
                      return "Enter a valid email";
                    }

                    // Fixed variable name and added lowercase normalization
                    final isValid = _universityDomains.values.any(
                          (domain) => trimmedValue.endsWith(domain.toLowerCase()),
                    );

                    if (!isValid) {
                      return 'Please use your official student email';
                    }

                    return null; // valid
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
                    } else if (value.length < 6) {
                      return 'Password too short (min 6 characters)';
                    }
                    return null;
                  },
                ),
                /*SizedBox(height: hightTen),
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
                      return 'Confirm password required';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),*/
                SizedBox(height: hightTen),
                CustomFormInput(
                  controller: _userNameController,
                  labelText: "User Name",
                  isObscured: false,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person,
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
                CustomDropdown(
                  value: _selectedGender,
                  items: gender,
                  labelText: 'Gender',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
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
                  onPressed: () async {
                    final bool isConnected = await checkNetworkAndShowSnackbar(context);
                    if (isConnected) {
                      if (!_isLoading) {
                        await _register();
                      }
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                      : const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blue900,
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
}

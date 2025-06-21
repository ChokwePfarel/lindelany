import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Constants/Constants.dart';
import '../Constants/Lists.dart';
import '../classes/user_model.dart';
import '../constants/scale.dart';
import '../create_edit/student/Create_student.dart';
import '../custom_made/widgets/customInput.dart';
import '../custom_made/widgets/custom_dropdown.dart';
import '../firebase_Set/user.dart';
import '../methods_Funtions/check_netwok.dart';
import '../transport_broadcast/userInteface/all_broadcasts.dart';
import '../user_interface/Common/Accommodations.dart';
import 'Auth.dart';
import 'logIn.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cornfirmPasswordController =
      TextEditingController();
  final TextEditingController _UserNameController = TextEditingController();

  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  String _selectedGender = gender.first;
  String _selectedUserType = userType.first;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _cornfirmPasswordController.text) {
        try {
          User? user = await _authService.createUserWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
            _UserNameController.text,
            _selectedUserType,
            _selectedGender,
          );

          if (user != null) {
            /*final userModel = UserModel(
              userId: user.uid,
              userName: _UserNameController.text.trim(),
              userType: _selectedUserType,
              userGender: _selectedGender,
              profilePictureUrl: '',
              isFreeTrial: true,

            );*/
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.fetchUser();


         /*   await context.read<UserProvider>().createUser(
              _UserNameController.text.trim(),
              _selectedUserType,
              _selectedGender,
              '',
              false,
              [],
            );*/

            //context.read<UserProvider>().setUser(userModel);

            final bool isStudent = _selectedUserType.toLowerCase() == 'student';

            if (isStudent) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CreateStudentProfile()));
            } else {
              _selectedUserType.toLowerCase() == 'transportation'
                  ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AllBroadcast()))
                  : Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Accomodations()));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account not created")));
          }
        } catch (e) {
          print(e.toString());
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      }
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
                SizedBox(
                  height: screenHeight * 0.104,
                ),
                SizedBox(
                  height: screenHeight * 0.078,
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
                SizedBox(
                  height: hightTen,
                ),
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
                    } else if (value.length < 9) {
                      return 'Password too short';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain at least one lowercase letter';
                    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain at least one digit';
                    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                        .hasMatch(value)) {
                      return 'Password must contain at least one special character';
                    }

                    return null;
                  },
                ),
                SizedBox(height: hightTen),
                CustomFormInput(
                  controller: _cornfirmPasswordController,
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
                  controller: _UserNameController,
                  labelText: "User name",
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
                      }),
                ),
                SizedBox(height: hightTen),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: CustomDropdown(
                      value: _selectedUserType,
                      items: userType,
                      labelText: 'User type',
                      onChanged: (newValue) {
                        _selectedUserType = newValue!;
                      }),
                ),
                SizedBox(height: screenHeight * 0.052),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: blue900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.nokora(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
                                  builder: (_) => const LoginPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Invalid credentials or user does not exist")),
                            );
                          }
                        },
                        child: Text(
                          'sign In',
                          style: TextStyle(
                            color: blue900,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

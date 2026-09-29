import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/constants/constants.dart';
import 'package:lindelany/constants/lists.dart';
import 'package:lindelany/custom_made/widgets/custom_dropdown.dart';
import 'package:lindelany/signIn&out/gate.dart';

import 'package:provider/provider.dart';
import '../../custom_made/widgets/customInput.dart';
import '../../firebase_Set/set_student.dart';
import '../../firebase_Set/user.dart';

class GoogleUserSetupPage extends StatefulWidget {
  const GoogleUserSetupPage({super.key});

  @override
  State<GoogleUserSetupPage> createState() => _GoogleUserSetupPageState();
}

class _GoogleUserSetupPageState extends State<GoogleUserSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedUserType = userType.first;
  String _selectedGender = gender.first;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();



  Future<void> _continue() async {

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);


      // Save user type and gender to Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'userName': _nameController.text.trim(),
        'userType': _selectedUserType,
        'userGender': _selectedGender,
        'isFreeTrial': true,
      });

      if (_selectedUserType.toLowerCase() == 'student') {
        await Provider.of<StudentProvider>(
          context,
          listen: false,
        ).createStudent(uid);

        await studentProvider.currentStudent(source: Source.server);
      }

      debugPrint('🔍 _register: Fetching user data to UserProvider...');
      await userProvider.fetchUser(source: Source.server);
      debugPrint(
        '✅ _register: User data fetched. Local User Type: ${userProvider.user?.userType}',
      );

      if (!mounted) return;

      // Gate will read userType and navigate correctly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Gate()),
      );
    } catch (e) {
      print('Setup error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20),

              CustomFormInput(
                controller: _nameController,
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

              const SizedBox(height: 16),


              CustomDropdown(
                value: _selectedUserType,
                items: userType,
                labelText: 'User Type',
                onChanged: (val) => setState(() => _selectedUserType = val!),
              ),

              const SizedBox(height: 16),

              CustomDropdown(
                value: _selectedGender,
                items: gender,
                labelText: 'Gender',
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: blue900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

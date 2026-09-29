import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/static/snackbar.dart';

import '../../Constants/lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/for_press/confirm_dialog.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../firebase_Set/set_student.dart';

import '../../methods_functions/check_netwok.dart';
import '../../models/student_model.dart';
import '../../static/utils.dart';
import '../../user_interface/Common/accommodations.dart';
import '../../Constants/constants.dart';
import '../../user_interface/common/settings.dart';

class CreateStudentProfile extends StatefulWidget {
  const CreateStudentProfile({super.key});

  @override
  State<CreateStudentProfile> createState() => _CreateStudentProfileState();
}

class _CreateStudentProfileState extends State<CreateStudentProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'StudentForm',
  );

  String _selectedPro = provinces.first;
  String _selectedUni = southAfricanUniversities.first;
  String _selectedYear = YearOfStudy.first;
  String _selectedPayment = Payment.first;

  late Stream<StudentModel> studentStream; // Will hold the stream later

  bool _hasChanged = false;

  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    studentStream = StudentProvider().currentStudentDoc();
    studentStream.listen((StudentModel student) {
      setState(() {
        _selectedPro = student.province;
        _selectedPayment = student.payment;
        _selectedYear = student.year;
        _selectedUni = student.uni;
      });
    });
  }

  Future<void> _saveProfile() async {
    //  Ensure dialog is closed if this function is called from the dialog.
    if (ModalRoute.of(context)?.isCurrent == false) {
      Navigator.pop(context); // Close the AlertDialog first
    }

  setState(() => _isLoading = true);

    String userId = _auth.currentUser!.uid;
    await _reference
        .doc(userId)
        .update({
          'userId': userId,
          'Province': _selectedPro,
          'Uni': _selectedUni,
          'Year': _selectedYear,
          'Payment': _selectedPayment,
        })
        .then((_) {
          //--------            --I used a call back instead of try n catch (e)
          CustomSnackbar.show(context, 'Saved Successfully');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Accomodations()),
          );
        })
        .catchError((error) {
          CustomSnackbar.show(context, 'Failed to save, try again later');
        });

  setState(() => _isLoading = false);
  }

  void _markAsDirty() {
    if (!_hasChanged) {
      setState(() {
        _hasChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = SizeConfig.screenHeight;

    final theme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_hasChanged,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!mounted) return;

        final action = await showUnsavedChangesDialog(
          context: context,
          onSave: () => _saveProfile(),
          titleStyle: theme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          buttonStyle: theme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        );

        if (!mounted) return;

        if (action == 'DISCARD') {
          // User chose to discard -> Manually pop the current screen (goes to MyProducts)
          Navigator.of(context).pop();
        } else if (action == 'SAVE') {
          // User chose to save -> Call the save function which uses pushReplacement
          _saveProfile();
        }
        // If action is 'CANCEL' or null, the dialog closes, and the user remains on the EditProduct screen.
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: blue900,

          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settingss()),
              );
            },
            icon: Icon(CupertinoIcons.settings, color: Colors.white, size: 25),
          ),

        ),
        body: StreamBuilder<StudentModel>(
          stream: studentStream,
          builder: (context, snapshot) {
            if (AsyncUtils.isLoadingOrError(snapshot)) {
              return AsyncUtils.BuildIsloadingOrError(snapshot);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: GlobalKey<FormState>(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        utils.getGreeting(),
                        style: theme.headlineMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: screenHeight * 0.010),

                      Text(
                        'Help Us Help You!',
                        style: theme.headlineMedium?.copyWith(
                          color: blue900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      customCard1(
                        colorr: blue900,
                        widgett: Text(
                          'To facilitate the process of getting a room,'
                          'it is advised to provide accurate information below',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.106),

                      Text(
                        'Student Form',
                        style: theme.headlineSmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.020),

                      // Province
                      CustomDropdown(
                        value: provinces.contains(_selectedPro)
                            ? _selectedPro
                            : provinces.first,
                        items: provinces,
                        labelText: 'Where are you from',
                        onChanged: (value) {
                          _selectedPro = value!;
                          _markAsDirty();
                        },
                      ),

                      SizedBox(height: screenHeight * 0.020),

                      // Institution
                      CustomDropdown<String>(
                        labelText: 'Institution',
                        items: southAfricanUniversities,
                        value: southAfricanUniversities.contains(_selectedUni)
                            ? _selectedUni
                            : southAfricanUniversities.first,
                        onChanged: (value) {
                          setState(() {
                            _selectedUni = value!;
                            _markAsDirty();
                          });
                        },
                      ),

                      SizedBox(height: screenHeight * 0.020),

                      // Year of Study
                      CustomDropdown(
                        value: YearOfStudy.contains(_selectedYear)
                            ? _selectedYear
                            : YearOfStudy.first,
                        items: YearOfStudy,
                        labelText: 'Current year of study',
                        onChanged: (value) {
                          _selectedYear = value!;
                          _markAsDirty();
                        },
                      ),
                      SizedBox(height: screenHeight * 0.020),

                      // Payment
                      CustomDropdown(
                        value: Payment.contains(_selectedPayment)
                            ? _selectedPayment
                            : Payment.first,
                        items: Payment,
                        labelText: 'How will you pay rent',
                        onChanged: (value) {
                          _selectedPayment = value!;
                          _markAsDirty();
                        },
                      ),

                      SizedBox(height: screenHeight * 0.020),

                      // Payment
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: blue900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            final bool isConnected = await checkNetworkAndShowSnackbar(
                              context,
                            );
                            if (isConnected) {
                              _saveProfile();
                            }
                          },
                          child:

                          _isLoading
                              ? SizedBox(
                            width: 20, // Adjust size as needed
                            height: 20, // Adjust size as needed
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0, // Makes the circle line thinner
                            ),
                          )
                              :
                          Text(
                            'SAVE',
                            style: theme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),

                      SizedBox(height: screenHeight * 0.090),

                      // Padding for safe bottom space
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/custom_made/widgets/custom_dropdown.dart';
import 'package:lindelany/static/snackbar.dart';

import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/setStudent.dart';
import '../../classes/student_model.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../static/utils.dart';
import '../../user_interface/Common/Accommodations.dart';
import '../../Constants/Constants.dart';
import '../../utility/utility_class.dart';

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

  Future<void> _savePro() async {
    String userId = _auth.currentUser!.uid;

    await _reference
        .doc(userId)
        .set({
          'userId': userId,
          'Province': _selectedPro,
          'Uni': _selectedUni,
          'Year': _selectedYear,
          'Payment': _selectedPayment,
        })
        .then((_) {
          //-----------------------------------I used a call back instead of try n catch (e)
          CustomSnackbar.show(context, 'Saved Successfully');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Accomodations()),
          );
        })
        .catchError((error) {
          CustomSnackbar.show(context, 'Failed to save, try again later');
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = SizeConfig.screenHeight;

    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blue900,

        actions: [
          TextButton(
            onPressed: () async {
              final bool isConnected = await checkNetworkAndShowSnackbar(
                context,
              );
              if (isConnected) {
                _savePro();
              }
            },
            child: Text(
              'UPDATE',
              style: theme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

                    SizedBox(width: screenHeight * 0.020),

                    Text(
                      'Help Us Help You!',
                      style: theme.headlineMedium?.copyWith(
                        color: blue900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.052),

                    customCard1(
                      colorr: blue900,
                      widgett: Text(
                        'To facilitate the process of getting a room,'
                        'it is advised to provide accurate information below',
                        style: theme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.104),

                    Text(
                      'Student Form',
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    // Province
                    CustomDropdown(
                      value: provinces.contains(_selectedPro)
                          ? _selectedPro
                          : provinces.first,
                      items: provinces,
                      labelText: 'Where are you from',
                      onChanged: (value) {
                        _selectedPro = value!;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.020),

                    // Institution
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            // IMPORTANT: Allows full width
                            initialValue:
                                southAfricanUniversities.contains(_selectedUni)
                                ? _selectedUni
                                : southAfricanUniversities.first,
                            decoration: InputDecoration(
                              labelText: 'Institution',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade900,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade900,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade900,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            items: southAfricanUniversities.map((String uni) {
                              return DropdownMenuItem(
                                value: uni,
                                child: Text(
                                  uni,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUni = value!;
                              });
                            },
                          ),
                        );
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
                      },
                    ),

                    SizedBox(height: screenHeight * 0.26),
                    // Padding for safe bottom space
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

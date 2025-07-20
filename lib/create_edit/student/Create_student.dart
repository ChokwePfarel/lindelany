
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/custom_made/widgets/custom_dropdown.dart';

import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/setStudent.dart';
import '../../classes/student_model.dart';
import '../../methods_Funtions/check_netwok.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Saved")));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Accomodations()),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Failed")));
        });
  }

  String getGreeting() {
    var hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;
    double hightTen = SizeConfig.heightUnit;
    double widthtTen = SizeConfig.heightUnit;
    final SizedBox sizedBoxHeight = SizedBox(height: hightTen);
    final SizedBox sizedBoxWidth = SizedBox(width: widthtTen);

    final theme = Theme.of(context).textTheme;

    //final user = context.watch<UserProvider>().user;

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
                      getGreeting(),
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: widthtTen),
                    SizedBox(width: widthtTen),

                    /*Text(
                      '${user?.userName}',
                      style: theme.headlineSmall?.copyWith(
                        color: blue900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),*/
                    Text(
                      'Help Us Help You!',
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.grey,
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

                    sizedBoxHeight,

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
                            value:
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
                              prefixIcon: Icon(
                                CupertinoIcons.book_fill,
                                color: blue900,
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

                    sizedBoxHeight,

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
                    sizedBoxHeight,

                    // Payment
                    CustomDropdown(
                      value: Payment.contains(_selectedPayment)
                          ? _selectedPayment
                          : Payment.first,
                      items: Payment,
                      labelText: 'How will pay rent',
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

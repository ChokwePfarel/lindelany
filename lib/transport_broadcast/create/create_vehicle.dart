import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Constants/Constants.dart';
import '../../constants/scale.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../user_interface/Common/Accommodations.dart';
import '../from_firebase/transport.dart';
import '../userInteface/all_broadcasts.dart';

class Vehicle extends StatefulWidget {
  const Vehicle({super.key});

  @override
  State<Vehicle> createState() => _VehicleState();
}

class _VehicleState extends State<Vehicle> {
  final _FormKey = GlobalKey<FormState>();

  final userId = FirebaseAuth.instance.currentUser!.uid;
  String carName = '';
  String brand = '';
  String numberPlate = '';
  String numbers = '';
  bool hasPaid = false;
  String plan = '';
  double amount = 0.0;
  String paymentId = '';
  DateTime createdAt = DateTime.now();

  _create() async {
    try {
      await createTransport().createVehicleProfile(
        carName,
        brand,
        numberPlate,
        numbers,
        hasPaid,
        plan,
        amount,
        paymentId,
        createdAt

      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created')));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    double hightTen = SizeConfig.heightUnit;

    return WillPopScope(
      onWillPop: () async {
        // Navigate to another page instead of allowing default back action
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Accomodations()),
        );
        return false; // Prevents default back action
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Car Profile',
            style: theme.bodyLarge?.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: blue900,
        ),

        backgroundColor: grey100,

        body: Form(
          key: _FormKey,
          child: Padding(
            padding: paddingg,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.10),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Car Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) => carName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name of the car';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: hightTen),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Brand |eg: FORD',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) => brand = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter the car brand';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: hightTen),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Number plate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) => brand = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Number plate';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: hightTen),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '081...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    initialValue: numbers,
                    onChanged: (value) => numbers = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter price';
                      } else if (value.length != 10) {
                        return '10 digits expected';
                      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: hightTen),

                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          if (_FormKey.currentState!.validate()) {
                            final bool isConnected =
                                await checkNetworkAndShowSnackbar(context);

                            if (isConnected) {
                              // Show loading indicator BEFORE execution
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                await _create(); // Wait for post creation

                                // Remove loading indicator
                                Navigator.of(context).pop();

                                // Navigate after success
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllBroadcast(),
                                  ),
                                );
                              } catch (e) {
                                Navigator.of(
                                  context,
                                ).pop(); // Dismiss loading on error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to create profile: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          'Save Profile',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

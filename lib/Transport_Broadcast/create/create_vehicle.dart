import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../methods_functions/check_netwok.dart';
import '../../payments/plans.dart';
import '../../payments/yoco.dart';
import '../from_firebase/transport.dart';
import '../userInteface/all_broadcasts.dart';

class Vehicle extends StatefulWidget {
  const Vehicle({super.key});

  @override
  State<Vehicle> createState() => _VehicleState();
}

class _VehicleState extends State<Vehicle> {
  final _FormKey = GlobalKey<FormState>();
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  final userId = FirebaseAuth.instance.currentUser!.uid;
  String _carName = '';
  String _brand = '';
  String _numberPlate = '';
  String _numbers = '';
  String _plan = '';
  int _amount = 0;
  String _paymentId = '';

  final DateTime _createdAt = DateTime.now();
  DateTime _paymentExpiryDate = DateTime.now();

  bool _hasFreeTrial = false;
  final bool _priority = false;

  Future<bool> _getHasFreeTrial() async {
    final doc = await _reference.collection('Users').doc(userId).get();
    _hasFreeTrial = doc.data()!['isFreeTrial'];
//    //     print(_hasFreeTrial);

    return _hasFreeTrial;
  }

  Future<void> _updateHasFreeTrial() async {
    await _reference.collection('Users').doc(userId).update({
      'isFreeTrial': false,
    });
  }

  Future<void> _handleFreeTrial() async {
    _updateHasFreeTrial();
    setState(() {
      _plan = freeTrialPlan.name;
      _amount = 0;
      _paymentId = 'free_trial_${DateTime.now().millisecondsSinceEpoch}';
      _paymentExpiryDate = YocoPaymentService.getExpiryDate(
        freeTrialPlan.durationMonths,
      );
    });
    _create(); // create listing with free trial

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AllBroadcast()),
        (route) => false,
      );
      return CustomSnackbar.show(context, 'Created Successfully');
    }
  }

  Future<void> _create() async {
    try {
      await CreateTransport().createVehicleProfile(
        _carName,
        _brand,
        _numberPlate,
        _numbers,
        _plan,
        _amount,
        _paymentId,
        _createdAt,
        _paymentExpiryDate,
        _priority,
      );
      CustomSnackbar.show(context, 'Saved successfully');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AllBroadcast()),
        (route) => false,
      );
    } catch (e) {
//      //       print(e.toString());
    }
  }

  Future<bool> _paymentsDialog(bool hasFreeTrial) async {
    final results = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: Center(
            child: Text(
              'Chose a Plan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: blue900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hasFreeTrial
                  ? GestureDetector(
                      onTap: () {
                        _handleFreeTrial();
                      },
                      child: customCard1(
                        colorr: Colors.grey,
                        widgett: Center(
                          child: Text(
                            'Free Trial(1 month)',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: blue900,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {},
                      child: customCard1(
                        colorr: blue900,
                        widgett: Column(
                          children: [
                            Text(
                              transportPlan.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'R${transportPlan.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
    return results ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    double hightTen = SizeConfig.heightUnit;

    final user = context.watch<UserProvider>().user;

    return Scaffold(
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.020),

                Text(
                  'Hi ${user?.userName}',
                  style: theme.headlineLarge?.copyWith(
                    color: blue900,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenHeight * 0.020),

                customCard1(
                  colorr: blue900,
                  widgett: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help Us Help You',
                        style: theme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.040),
                      Text(
                        'Please complete the form below and save.',
                        style: theme.bodyMedium!.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.040),

                Text(
                  'Vehicle Form',
                  style: theme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                inputField(
                  label: 'Car Name',
                  validationNote: 'Name of the car required',
                  initialValue: _carName,
                  onChanged: (val) => _carName = val,
                ),

                SizedBox(height: hightTen),

                inputField(
                  label: 'Brand',
                  validationNote: 'Enter your car brand (eg. Toyota)',
                  initialValue: _brand,
                  onChanged: (val) => _brand = val,
                ),

                SizedBox(height: hightTen),

                inputField(
                  label: 'Number plate',
                  validationNote: 'Enter number plate',
                  initialValue: _numberPlate,
                  onChanged: (val) => _numberPlate = val,
                ),

                SizedBox(height: hightTen),

                inputField(
                  label: 'Phone number',
                  validationNote: 'Enter 10 digits phone number',
                  initialValue: _numbers,
                  onChanged: (val) => _numbers = val,
                ),

                SizedBox(height: hightTen),
                SizedBox(height: hightTen),

                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (_FormKey.currentState!.validate()) {
                        final bool isConnected =
                            await checkNetworkAndShowSnackbar(context);

                        final results = await _getHasFreeTrial();
                        final paymentSuccess = await _paymentsDialog(results);
                        //_create();
                      }
                    },
                    child: Text(
                      'Save',
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget inputField({
    required String label,
    required String validationNote,
    required String initialValue,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: label.toLowerCase().contains('phone')
          ? TextInputType.phone
          : TextInputType.text,
      // Set keyboard type based on the field
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onChanged: (value) => onChanged(value.toUpperCase().trim()),
      validator: (value) {
        if (value == null || value.isEmpty || value.length > 25) {
          return validationNote;
        }
        // Only check for 10 digits if the label is 'Phone number'
        if (label.toLowerCase().contains('phone')) {
          final trimmed = value.trim();
          final isNumeric = RegExp(r'^\d{10}$').hasMatch(trimmed);
          if (!isNumeric) {
            return 'Phone number must be exactly 10 digits';
          }
        }
        return null;
      },
    );
  }
}

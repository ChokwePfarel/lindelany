import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/payments/yoco.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../payments/plans.dart';
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
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  final SubscriptionPlan transportPlan = SubscriptionPlan(
    name: '1 Month',
    durationMonths: 1,
    price: 100.0,
  );

  final userId = FirebaseAuth.instance.currentUser!.uid;
  String _carName = '';
  String _brand = '';
  String _numberPlate = '';
  String _numbers = '';
  String _plan = '';
  double _amount = 0.0;
  String _paymentId = '';
  DateTime _createdAt = DateTime.now();
  Timestamp _paymentExpiryDate = Timestamp.fromDate(DateTime.now());
  bool _hasFreeTrial = false;
  bool _priority = false;

  Future<bool> _getHasFreeTrial() async {
    final doc = await _reference.collection('Users').doc(userId).get();
    _hasFreeTrial = doc.data()!['isFreeTrial'];
    print(_hasFreeTrial);

    return _hasFreeTrial;
  }

  Future<void> _updateHasFreeTrial() async {
    await _reference.collection('Users').doc(userId).update({
      'isFreeTrial': false,
    });
  }

  void _handlePayment(SubscriptionPlan plan) async {
    final isSuccess = await YocoPaymentService.processPayment(plan);

    if (!isSuccess) {
      CustomSnackbar.show(context, 'Payment failed. Please try again.');
      return;
    }

    final expiryDate = YocoPaymentService.getExpiryDate(plan.durationMonths);
    setState(() {
      _plan = plan.name;
      _amount = plan.price;
      _paymentId = 'dummy_payment_id_${DateTime.now().millisecondsSinceEpoch}';
      _createdAt = expiryDate;
    });
    _create();
  }

  Future<void> _handleFreeTrial() async {
    _updateHasFreeTrial();
    setState(() {
      _plan = freeTrialPlan.name;
      _amount = 0.0;
      _paymentId = 'free_trial_${DateTime.now().millisecondsSinceEpoch}';
      _paymentExpiryDate = Timestamp.fromDate(
        YocoPaymentService.getExpiryDate(freeTrialPlan.durationMonths),
      );
    });

    _create(); // create listing with free trial
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
        _priority
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created')));
    } catch (e) {
      print(e.toString());
    }
  }

  void _paymentsDialog(bool hasFreeTrial) {
    showDialog(
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
              hasFreeTrial ?
                GestureDetector(
                  onTap: () {
                    _handleFreeTrial();


                  },
                  child: customCard1(
                    colorr: Colors.grey,
                    widgett: Center(
                      child: Text(
                        'Free Trial(R0.00)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: blue900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ) :

              GestureDetector(
                onTap: () {
                  _handlePayment(transportPlan);

                },
                child: customCard1(
                  colorr: blue900,
                    widgett: Column(children: [

                  Text(
                    transportPlan.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'R${transportPlan.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],)),
              )

            ],
          ),
        );
      },
    );
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
                  onChanged: (value) => _carName = value,
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
                  onChanged: (value) => _brand = value,
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
                  onChanged: (value) => _numberPlate = value,
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
                  initialValue: _numbers,
                  onChanged: (value) => _numbers = value.toUpperCase(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid number';
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
                    width: 250,
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
                            final results = await _getHasFreeTrial();

                            CustomDialog.showLoading(context, 'Saving...');

                            _paymentsDialog(results);


                          } else{ CustomSnackbar.show(context, 'No network connection');}

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

                TextButton(onPressed: () async {

          final bool isConnected =
          await checkNetworkAndShowSnackbar(context);

          if (isConnected) {
          final results = await _getHasFreeTrial();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(

                child: CircularProgressIndicator()),
          );
          _paymentsDialog(results);

          if (mounted) Navigator.of(context).pop(); // close loading
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  AllBroadcast()),
                  (route) => false,
            );
          }


          } else{ CustomSnackbar.show(context, 'No network connection');}

          },child: Text('Testing'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

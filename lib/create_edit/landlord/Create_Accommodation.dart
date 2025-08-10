import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/payments/yoco.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/myAccommodations.dart';
import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/editableFiled.dart';
import '../../firebase_Set/houseListing.dart';
import '../../payments/plans.dart';
import '../../payments/webview.dart';

class CreateAcc extends StatefulWidget {
  const CreateAcc({super.key});

  @override
  State<CreateAcc> createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  final _userId = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  String _accommodationName = '';
  String _location = '';
  double _double = 0;
  double _single = 0;
  String _numbers = '';
  String _about = '';
  bool _nsfas = false;
  bool _isWifi = false;
  final bool _isParking = false;
  final bool _full = false;
  bool _laundry = false;
  bool _tv = false;
  bool _security = false;
  bool _transport = false;
  bool _kitchen = false;
  bool _bed = false;
  bool _shower = false;
  String _selectedProvince = provinces.first;
  String _selectedGenders = genders.first;
  String _selectedType = Typee.first;
  String _available = Availability.first;
  String _aboutPayment = '';
  final List<String> _imagesUrl = [];
  final String _picture = '';
  final bool _isTexted = false;
  String _selectedUni = southAfricanUniversities.first;

  String _plan = '';
  double _amount = 0.0;
  final Timestamp _createdAt = Timestamp.fromDate(DateTime.now());
  Timestamp _paymentExpiryDate = Timestamp.fromDate(DateTime.now());
  String _paymentId = '';

  Future<void> _updateHasFreeTrial() async {
    await _reference.collection('Users').doc(_userId).update({
      'isFreeTrial': false,
    });
  }

  bool hasFreeTrial = false;

  Future<bool> _getHasFreeTrial() async {
    final doc = await _reference.collection('Users').doc(_userId).get();
    hasFreeTrial = doc.data()!['isFreeTrial'];
    print('current user has free trial ?? $hasFreeTrial');

    return hasFreeTrial;
  }

  Future<void> _handlePayment( String token, SubscriptionPlan plan,) async {
    final isSuccess = await YocoPaymentService.chargeCardToken(token, plan);

    if (!isSuccess) {
      CustomSnackbar.show(context, 'Payment failed. Please try again.');
      return;
    }

    final expiryDate = YocoPaymentService.getExpiryDate(plan.durationMonths);

    setState(() {
      _plan = plan.name;
      _amount = plan.price;
      _paymentId = token;
      _paymentExpiryDate = Timestamp.fromDate(expiryDate);
    });


    //CustomDialog.showLoading(context, 'Saving...');
    await create(); // assuming create() is async
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyListing()),
            (route) => false,
      );
    }


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

    //CustomDialog.showLoading(context, 'Saving...');
    await create(); // assuming create() is async

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyListing()),
            (route) => false,
      );
    }
  }

  Future<bool> _paymentsDialog(bool hasFreeTrial) async {
    final result = await showDialog<bool>(
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
              //if hasFreeTrial is true,show free trial button which
              if (hasFreeTrial)
                GestureDetector(
                  onTap: () {
                    _handleFreeTrial();
                  },
                  child: customCard1(
                    colorr: Colors.grey,
                    widgett: Column(
                      children: [
                        Text(
                          'Free Trial',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: blue900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: SizeConfig.screenHeight*0.004),

                        Text(
                          'R${freeTrialPlan.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: blue900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ...subscriptionPlans.map((plan) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YocoWebView(
                          amountInCents: (plan.price * 100).toInt(),
                          publicKey: 'pk_test_ed3c54a6gOol69qa7f45',
                          onSuccess: (token) => _handlePayment(token, plan),
                          onError: (error) {
                            CustomSnackbar.show(context, 'Payment error: $error');
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customCard1(
                      colorr: blue900,
                      isPadding: paddingg,
                      widgett: Column(
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight*0.004),
                          Text(
                            'R${plan.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        );
      },
    );
    return result ?? false; // default to false if dialog was dismissed
  }

  bool _validateFormAndFields() {
    String? error;

    if ((error = _requiredValidator(_accommodationName)) != null) {
      CustomSnackbar.show(context, "Accommodation Name: $error");
      return false;
    }
    if ((error = _requiredValidator(_location)) != null) {
      CustomSnackbar.show(context, "Area/City: $error");
      return false;
    }
    if ((error = _requiredDescriptionValidator(_about)) != null) {
      CustomSnackbar.show(context, "About Accommodation: $error");
      return false;
    }
    if ((error = _requiredDescriptionValidator(_aboutPayment)) != null) {
      CustomSnackbar.show(context, "About Payments: $error");
      return false;
    }
    if ((error = _phoneValidator(_numbers)) != null) {
      CustomSnackbar.show(context, "Phone Number: $error");
      return false;
    }
    if ((error = _amountValidator(_single.toString())) != null) {
      CustomSnackbar.show(context, "Single Room: $error");
      return false;
    }
    if ((error = _amountValidator(_double.toString())) != null) {
      CustomSnackbar.show(context, "Double Room: $error");
      return false;
    }

    // Also validate dropdown fields
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.show(context, 'Please fill in all required fields.');
      return false;
    }
    return true; // Everything passed
  }


  Future<void> create() async {
    try {
      await Listing().createListing(
        _userId!,
        _accommodationName,
        _location,
        _selectedUni,
        _nsfas,
        _isWifi,
        _isParking,
        _numbers,
        _about,
        _double,
        _single,
        _full,
        _selectedProvince,
        _selectedGenders,
        _selectedType,
        _available,
        _aboutPayment,
        _laundry,
        _tv,
        _security,
        _transport,
        _kitchen,
        _bed,
        _shower,
        _imagesUrl,
        _picture,
        _plan,
        _amount,
        _paymentId,
        _createdAt,
        _paymentExpiryDate,
        _isTexted,
      );
    } catch (e) {
      CustomSnackbar.show(context, 'Failed to create listing');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final SizedBox sizedBoxHeight = SizedBox(height: SizeConfig.screenHeight * 0.010);
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        title: Text(
          "Create profile",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: blue900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello there',
                  style: theme.headlineLarge?.copyWith(
                    color: blue900,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.020),
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
                        'Insure to provide all and accurate information for smooth interaction with potential tenants',
                        style: theme.bodyMedium!.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight* 0.060),

                Text(
                  'Accommodation Form',
                  style: theme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      buildEdditable(
                        title: 'Accommodation Name',
                        value: _accommodationName.trim(),
                        onSave: (val) => setState(() {
                          _accommodationName = val;
                        }),
                        hintText: 'Name',
                        validator: _requiredValidator,
                      ),
                      buildEdditable(
                        title: 'Area/City',
                        value: _location.trim(),
                        onSave: (val) => setState(() {
                          _location = val;
                        }),
                        hintText: 'Area',
                        validator: _requiredValidator,
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight,
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      Padding(
                        padding: paddingg,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Accommodation type',
                          ),
                          value: _selectedType,
                          items: Typee.map((String type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (Value) {
                            setState(() {
                              _selectedType = Value!;
                            });
                          },
                        ),
                      ),
                      sizedBoxHeight,
                      Padding(
                        padding: paddingg,
                        child: DropdownButtonFormField(
                          value: _selectedGenders,
                          decoration: InputDecoration(
                            labelText: 'Gender Accommodated',
                          ),
                          items: genders.map((String genders) {
                            return DropdownMenuItem(
                              value: genders,
                              child: Text(genders),
                            );
                          }).toList(),
                          onChanged: (Value) {
                            setState(() {
                              _selectedGenders = Value!;
                            });
                          },
                        ),
                      ),
                      sizedBoxHeight,
                      Padding(
                        padding: paddingg,
                        child: DropdownButtonFormField(
                          value: _available,
                          decoration: InputDecoration(
                            labelText: 'Available spaces',
                          ),
                          items: Availability.map((String available) {
                            return DropdownMenuItem(
                              value: available,
                              child: Text(available),
                            );
                          }).toList(),
                          onChanged: (Value) {
                            setState(() {
                              _available = Value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight,
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      buildEdditable(
                        title: 'About Accommodation',
                        value: _about,
                        onSave: (val) => setState(() {
                          _about = val;
                        }),
                        hintText: 'Description of the accommo...',
                        validator: _requiredDescriptionValidator,
                      ),
                      buildEdditable(
                        title: 'About payments',
                        value: _aboutPayment,
                        onSave: (val) => setState(() {
                          _aboutPayment = val;
                        }),
                        hintText: 'A deposit of R2000 is required..',
                        validator: _requiredDescriptionValidator,
                      ),
                      buildEdditable(
                        title: 'Phone Number',
                        value: _numbers.trim(),
                        onSave: (val) => setState(() {
                          _numbers = val;
                        }),
                        hintText: '081...',
                        validator: _phoneValidator,
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight,
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedProvince,
                          decoration: const InputDecoration(
                            labelText: 'Province',
                          ),
                          items: provinces.map((province) {
                            return DropdownMenuItem(
                              value: province,
                              child: Text(province),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedProvince = value;
                              });
                            }
                          },
                        ),
                      ),

                      sizedBoxHeight,

                      //Drop
                      Padding(
                        padding: paddingg,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                // IMPORTANT: Allows full width
                                value: _selectedUni,
                                decoration: InputDecoration(
                                  labelText: 'Institution',
                                ),
                                items: southAfricanUniversities.map((
                                  String uni,
                                ) {
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
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight,
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      buildEdditable(
                        title: 'Single Room',
                        value: _single.toString(),
                        onSave: (val) => setState(() {
                          _single = double.tryParse(val) ?? _single;
                        }),
                        // Convert back to double safely                      validator
                        validator: _amountValidator,
                        hintText: '3000',
                      ),
                      buildEdditable(
                        title: 'Double room',
                        value: _double.toString(),
                        onSave: (val) => setState(() {
                          _double = double.tryParse(val) ?? _double;
                        }),
                        validator: _amountValidator,
                        hintText: 'R2500',
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight,
                Text(
                  'Indicate available amenities & services by checking the circles',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                ),
                sizedBoxHeight,
                Container(
                  decoration: border10,
                  child: SwitchListTile(
                    title: const Text(
                      'NSFAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Toggle the switch if your accommodation is NSFAS accredited',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _nsfas,
                    onChanged: (bool? value) {
                      setState(() {
                        _nsfas = value!;
                      });
                    },
                  ),
                ),
                sizedBoxHeight,
                customCard1(
                  isPadding: paddingg,
                  colorr: Colors.grey.shade600,
                  widgett: Column(
                    children: [
                      _row('Study area', _tv, () {
                        setState(() {
                          _tv = !_tv;
                        });
                      }),
                      divider,
                      _row('Sleeping bed', _bed, () {
                        setState(() {
                          _bed = !_bed;
                        });
                      }),
                      divider,
                      _row('WI_FI provided', _isWifi, () {
                        setState(() {
                          _isWifi = !_isWifi;
                        });
                      }),
                      divider,
                      _row('Kitchen', _kitchen, () {
                        setState(() {
                          _kitchen = !_kitchen;
                        });
                      }),
                      divider,
                      _row('Laundry machine', _laundry, () {
                        setState(() {
                          _laundry = !_laundry;
                        });
                      }),
                      divider,
                      _row('Water included', _shower, () {
                        setState(() {
                          _shower = !_shower;
                        });
                      }),
                      divider,
                      _row('Electricity included', _security, () {
                        setState(() {
                          _security = !_security;
                        });
                      }),
                      divider,
                      _row('Transport provided', _transport, () {
                        setState(() {
                          _transport = !_transport;
                        });
                      }),
                    ],
                  ),
                ),
                sizedBoxHeight,
                sizedBoxHeight,
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
                     if (!_validateFormAndFields()) return;

                      final results = await _getHasFreeTrial();

                      final paymentSuccess = await _paymentsDialog(results);

                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                sizedBoxHeight,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String title, bool isSelected, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.015),
        // Adjust spacing if needed
        GestureDetector(
          onTap: onTap,
          child: Icon(
            isSelected ? Icons.check_circle : Icons.circle,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }

  //Validators
  String? _requiredDescriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 30) return 'Say more';
    return null;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';
    if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _amountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter price';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}

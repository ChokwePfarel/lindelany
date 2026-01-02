import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/payments/yoco.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/my_listing.dart';
import '../../Constants/constants.dart';
import '../../constants/lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../custom_made/widgets/editableFiled.dart';
import '../../firebase_Set/set_listing.dart';
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

  late String _listingId = '';


  final List<String> _imagesUrl = [];
  final String _picture = '';
  final Timestamp _createdAt = Timestamp.fromDate(DateTime.now());
  Timestamp _paymentExpiryDate = Timestamp.fromDate(DateTime.now());
  final bool _isTexted = false;
  final bool _isParking = false;
  final bool _full = false;
  bool _laundry = false;
  bool _tv = false;
  bool _security = false;
  bool _transport = false;
  bool _kitchen = false;
  bool _bed = false;
  bool _shower = false;
  bool _nsfas = false;
  bool _isWifi = false;
  final bool _isVerified = false;
  bool _isWalkable = false;
  int _double = 0;
  int _single = 0;
  int _amount = 0;
  String _selectedProvince = provinces.first;
  String _selectedGenders = genders.first;
  String _selectedType = Typee.first;
  String _available = Availability.first;
  String _aboutPayment = '';
  String _accommodationName = '';
  String _location = '';
  String _numbers = '';
  String _about = '';
  String _selectedUni = southAfricanUniversities.first;
  String _plan = '';
  String _paymentId = '';
  String _status = 'inactive';
  String _address = '';
  String _city = cities.first;
  String _postalCode = '';
  final String _verificationStatus = 'notVerified';

  //----------------------------------Create Funtion----------------------------

  Future create() async {
    try {
      String newListingId = await Listing().createListing(
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
        _status,
        _isWalkable,
        _isVerified,
        _address,
        _city,
        _postalCode,
        _verificationStatus,
      );

      if (newListingId.isNotEmpty && mounted) {
        setState(() {
          _listingId = newListingId;
        });
      }
    } catch (e) {
      CustomSnackbar.show(context, 'Failed to create listing');
    }
  }

  //----------------------------------Update free trial-------------------------

  Future<void> _updateHasFreeTrial() async {
    await _reference.collection('Users').doc(_userId).update({
      'isFreeTrial': false,
    });
  }

  //--------------------------Check has free trial------------------------------

  bool hasFreeTrial = false;

  Future<bool> _getHasFreeTrial() async {
    final doc = await _reference.collection('Users').doc(_userId).get();
    setState(() {
      hasFreeTrial = doc.data()!['isFreeTrial'];
    });
//    //     print('current user has free trial ?? $hasFreeTrial');

    return hasFreeTrial;
  }

  //-----------------------------------Dialog for payment-----------------------

  Future<bool> _paymentsDialog() async {
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
              ...subscriptionPlans.map((plan) {
                return GestureDetector(
                  onTap: () async {
                    //await _startPayment();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YocoWebView(
                          plan: plan,
                          collection: 'Accommodation',
                          docId: _listingId,
                        ),
                      ),
                    );

//                    print('PASSED ID: $_listingId');
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.004),
                          Text(
                            'R${plan.price.toStringAsFixed(2)}',
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
                );
              }),
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
      CustomSnackbar.show(context, "Area: $error");
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

  //-------------------create partial------------------------------------------

  Future<void> _createPartialAccom(bool hasFreeTrial) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: blue900)),
    );

    // If user has free trial
    if (hasFreeTrial) {
      _status = 'active';
      _plan = freeTrialPlan.name;
      _amount = 0;
      _paymentId = 'free_trial_${DateTime.now().millisecondsSinceEpoch}';
      _paymentExpiryDate = Timestamp.fromDate(
        YocoPaymentService.getExpiryDate(freeTrialPlan.durationMonths),
      );

      // Mark the free trial as used
      await _updateHasFreeTrial();
    } else {
      _status = 'inactive';
    }

    await create(); // Creates accommodation doc

    if (mounted) Navigator.of(context).pop(); // Close loading dialog
  }

  //----------------------------------------------------------------------------

  bool _hasChange = false;

  void _markAsDirty(){
    if(!_hasChange){
      setState(() {
        _hasChange = true;
      });
    }
  }

  //----------------------------------------------------------------------------

  Future<String?> _dialog({
    String cancelLabel = 'CANCEL',
    String exitLabel = 'EXIT',
}){
    return showDialog<String>(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,

        actions: [

          TextButton(onPressed: ()=> Navigator.of(context).pop('CANCEL'),
              child: Text(cancelLabel,style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: blue900,
                fontWeight: FontWeight.bold,
              ),),),

          TextButton(onPressed: ()=> Navigator.of(context).pop('EXIT'),
              child: Text(exitLabel,style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.red,
                fontWeight: FontWeight.bold
              )))
        ],
      );
  });}



  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final SizedBox sizedBoxHeight = SizedBox(
      height: SizeConfig.screenHeight * 0.010,
    );
    final theme = Theme.of(context).textTheme;

    return PopScope(

      canPop: !_hasChange,
      onPopInvokedWithResult: (didPop, results) async {
        if (didPop) return;
        if (!mounted) return;

        final action = await _dialog();

        if(!mounted) results;

        if(action == 'EXIT'){
          Navigator.of(context).pop();
        }
      },

      child: Scaffold(
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
                  SizedBox(height: SizeConfig.screenHeight * 0.060),

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
                          hintText: 'House Name',
                          validator: _requiredValidator,
                        ),
                        buildEdditable(
                          title: 'Area',
                          value: _location.trim(),
                          onSave: (val) => setState(() {
                            _location = val;
                          }),
                          hintText: 'Belleville South',
                          validator: _requiredValidator,
                        ),

                        buildEdditable(
                          title: 'Street Address',
                          value: _address,
                          onSave: (val) => setState(() {
                            _address = val;
                          }),
                          hintText: '18 Franklin Street',
                          validator: _requiredAddressValidator,
                        ),

                        Padding(
                          padding: paddingg,
                          child: DropdownButtonFormField(
                            borderRadius: BorderRadius.circular(20),
                            initialValue: _city,
                            decoration: InputDecoration(
                              labelText: 'City',
                            ),
                            items: cities.map((String City) {
                              return DropdownMenuItem(
                                value: City,
                                child: Text(City),
                              );
                            }).toList(),
                            onChanged: (Value) {
                              setState(() {
                                _city = Value!;
                                _markAsDirty();
                              });
                            },
                          ),
                        ),

                        buildEdditable(
                          title: 'Postal Code',
                          value: _postalCode,
                          onSave: (val) => setState(() {
                            _postalCode = val;
                          }),
                          hintText: '',
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
                            initialValue: _selectedType,
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
                            borderRadius: BorderRadius.circular(20),
                            initialValue: _selectedGenders,
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
                            borderRadius: BorderRadius.circular(20),
                            initialValue: _available,
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
                                _markAsDirty();

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
                          hintText: 'Description',
                          validator: _requiredDescriptionValidator,
                        ),
                        buildEdditable(
                          title: 'About payments',
                          value: _aboutPayment,
                          onSave: (val) => setState(() {
                            _aboutPayment = val;

                          }),
                          hintText: 'eg: We require a deposit of R1500 ',
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
                  sizedBoxHeight,

                  Text(
                    'Targeted University',
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: blue900,
                    ),
                  ),

                  customCard1(
                    colorr: Colors.grey,
                    widgett: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomDropdown(
                            value: provinces.contains(_selectedProvince)
                                ? _selectedProvince
                                : provinces.first,
                            items: provinces,
                            labelText: '',
                            onChanged: (value) {
                              _selectedProvince = value!;
                            },
                          ),
                        ),
                        //Drop
                        Padding(
                          padding: paddingg,
                          child: CustomDropdown<String>(
                            labelText: '',
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
                        ),
                      ],
                    ),
                  ),

                  sizedBoxHeight,
                  sizedBoxHeight,

                  Text(
                    'Prices',
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: blue900,
                    ),
                  ),

                  customCard1(
                    colorr: Colors.grey,
                    widgett: Column(
                      children: [
                        buildEdditable(
                          title: 'Single Room',
                          value: _single.toString(),
                          onSave: (val) => setState(() {
                            _single = int.tryParse(val) ?? _single;
                          }),
                          // Convert back to double safely                      validator
                          validator: _amountValidator,
                          hintText: '3000',
                        ),
                        buildEdditable(
                          title: 'Double room',
                          value: _double.toString(),
                          onSave: (val) => setState(() {
                            _double = int.tryParse(val) ?? _double;
                          }),
                          validator: _amountValidator,
                          hintText: 'R2500',
                        ),
                      ],
                    ),
                  ),

                  sizedBoxHeight,
                  sizedBoxHeight,

                  Text(
                    'Indicate available amenities & services by checking the circles.',
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
                        'Toggle the switch if this accommodation is NSFAS accredited',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _nsfas,
                      onChanged: (bool? value) {
                        setState(() {
                          _nsfas = value!;
                          _markAsDirty();

                        });
                      },
                    ),
                  ),

                  sizedBoxHeight,

                  Container(
                    decoration: border10,
                    child: SwitchListTile(
                      title: const Text(
                        'Can students walk to campus from this location?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'We recommend selecting “Yes/On” if it’s under 2 km or 20 minutes on foot. ',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _isWalkable,
                      onChanged: (bool? value) {
                        setState(() {
                          _isWalkable = value!;
                          _markAsDirty();

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

                        await _createPartialAccom(results);

                        if (!mounted) return;

                        if (_listingId.isEmpty) {
                          CustomSnackbar.show(
                            context,
                            'Failed to initialize listing.',
                          );
                          return;
                        }

                        if (results) {
                          // Free trial → go straight to MyListing page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MyListing()),
                            (route) => false,
                          );
                        } else {
                          // Non-free trial → proceed to payment dialog
                          await _paymentsDialog();
                        }
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
                ],
              ),
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
    if (value.length < 30) return 'Please Say More';
    return null;
  }
  String? _requiredAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length > 30) return 'Street Address Only';
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

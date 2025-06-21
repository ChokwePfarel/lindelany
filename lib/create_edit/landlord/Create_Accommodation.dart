import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/editableFiled.dart';
import '../../firebase_Set/houseListing.dart';
import '../../firebase_Set/user.dart';

class CreateAcc extends StatefulWidget {
  const CreateAcc({super.key});

  @override
  State<CreateAcc> createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Accommodation',);

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

  final String _plan = '';
  final double _amount = 0.0;
  final Timestamp _createdAt = Timestamp.fromDate(DateTime.now());
  final Timestamp _paymentExpiryDate = Timestamp.fromDate(DateTime.now());
  final String _paymentId = '';
  //bool _hasFreeTrial = true;



  //UPDATE hasTrial to false when a user creates an accommodation
  //using free trial
  Future<void> _updateHasFreeTrial(String docId) async {
    try{
      await _reference.doc(docId).update({
        'hasFreeTrial': false,
    } );}catch (e){
      print('failed to update hasFreeTrial : ${e.toString()}');
    }
  }


  Widget _paymentsDialog(bool hasFreeTrial){
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //if hasFreeTrial is true,show free trial button which
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
              onPressed: () async {
                _updateHasFreeTrial('');
                create();
                //After creation, count down should start.
              },
              child: Text('Free trial',style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white,)),
          ),

          ElevatedButton(
              onPressed: () async {

                //BEGIN YOCO PAYMENTS

                //Call create method when successfull.
                //And update hasPaid to true,
                //When plan expires, we should update hasPaid to false
              },
              child: Text('One month',style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white,)),
          ),

          //MORE Buttons

        ]
      )
    );
  }


  void create() async {
    String? error;
    if ((error = _requiredValidator(_accommodationName)) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Accommodation name: $error")));
      return;
    }
    if ((error = _requiredValidator(_location)) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Area/City: $error")));
      return;
    }
    if ((error = _requiredDescriptionValidator(_about)) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("About Accommodation: $error")));
      return;
    }
    if ((error = _requiredDescriptionValidator(_aboutPayment)) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("About payments: $error")));
      return;
    }
    if ((error = _phoneValidator(_numbers)) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Phone Number: $error")));
      return;
    }
    if ((error = _amountValidator(_single.toString())) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Single Room: $error")));
      return;
    }
    if ((error = _amountValidator(_double.toString())) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Double Room: $error")));
      return;
    }

    // Validate dropdowns using the parent Form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all dropdown fields")),
      );
      return;
    }

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
        //_hasFreeTrial,
      );
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;
    double hightTen = SizeConfig.heightUnit;
    double widthtTen = SizeConfig.heightUnit;
    final SizedBox sizedBoxHeight = SizedBox(height: hightTen);
    final SizedBox sizedBoxWidth = SizedBox(width: widthtTen);
    final theme = Theme.of(context).textTheme;

    final user = context.watch<UserProvider>().user;


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
                  'Hi ${user?.userName}',
                  style: theme.headlineSmall?.copyWith(
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
                        style: theme.headlineLarge!
                            .copyWith(
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
                const SizedBox(height: 60),

            Text(
              'Accommodation details',
              style: theme.headlineMedium!
                  .copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),),
                customCard1(
                  colorr: Colors.grey,
                  widgett: Column(
                    children: [
                      buildEdditable(
                        title: 'Accommodation name',
                        value: _accommodationName,
                        onSave: (val) => setState(() {
                          _accommodationName = val;
                        }),
                        hintText: 'Name',
                        validator: _requiredValidator,
                      ),
                      buildEdditable(
                        title: 'Area/City',
                        value: _location,
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
                            labelText: 'Gender accommodated',
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
                        hintText: 'eg: A deposit of R2000 is required..',
                        validator: _requiredDescriptionValidator,
                      ),
                      buildEdditable(
                        title: 'Phone Number',
                        value: _numbers,
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    onPressed: create,
                    child: const Text(
                      'Create Profile',
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
        SizedBox(width: SizeConfig.screenWidth * 0.015), // Adjust spacing if needed
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
    if (value.length < 50) return 'Say more';
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

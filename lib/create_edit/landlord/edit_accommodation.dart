import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/myAccommodations.dart';
import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/houseListing.dart';
import '../../utility/utility_class.dart';

class EditAccom extends StatefulWidget {
  final Listing_model listing;

  const EditAccom({super.key, required this.listing});

  @override
  State<EditAccom> createState() => _EditAccomState();
}

class _EditAccomState extends State<EditAccom> {
  final CollectionReference reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );
  final _formkey = GlobalKey<FormState>();

  double? _singleRoomPrice;
  double? _doubleRoomPrice;
  String? _phoneNumbers;
  bool _isFull = false;
  String? _selectedGenders;
  String? _selectedType;
  String? _availableRooms;
  String? _aboutPayment;
  String? _aboutAccom;

  late Stream<Listing_model> _listingStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listingStream = Listing().CurrentUserListing(
      widget.listing.accommodationId,
    );

    _listingStream.listen((Listing_model instance) {
      _singleRoomPrice = instance.singleRoomPrice;
      _doubleRoomPrice = instance.doubleRoomPrice;
      _phoneNumbers = instance.phoneNumbers;
      _isFull = instance.isFull;
      _selectedGenders = instance.genders;
      _selectedType = instance.typeOfAccom;
      _availableRooms = instance.availableRooms;
      _aboutPayment = instance.aboutPayment;
      _aboutAccom = instance.aboutAccom;
    });
  }

  //----------------------------------------------------------------------------
  //UPDATE METHOD
  Future<void> _updateUserProfile() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      try {
        await reference.doc(widget.listing.accommodationId).update({
          'aboutAccom': _aboutAccom,
          'singleRoomPrice': _singleRoomPrice,
          'doubleRoomPrice': _doubleRoomPrice,
          'phoneNumbers': _phoneNumbers,
          'aboutPayment': _aboutPayment,
          'isFull': _isFull,
          'typeOfAccom': _selectedType,
          'availableRooms' : _availableRooms
        });
        if(mounted) {
          CustomSnackbar.show(context, 'Updated');
        }
      } catch (e) {
        if(mounted) {
          CustomSnackbar.show(context, 'Failed to update,try again later');
        } }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final SizedBox sizedBoxHeight = SizedBox(height: SizeConfig.screenHeight * 0.010);
    final SizedBox sizedBoxWidth = SizedBox(width: SizeConfig.screenWidth * 0.010);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,

        actions: [
          TextButton(
            onPressed: () {
              CustomDialog.showLoading(context, 'Updating...');
              _updateUserProfile();
              if(mounted) Navigator.pop(context);
              if(mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context)=> MyListing()),
                        (route) => false);
              }

            },
            child: Text(
              'UPDATE',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder(
        stream: _listingStream,
        builder: (Context, snapshot) {
          if (AsyncUtils.isLoadingOrError(snapshot)) {
            return AsyncUtils.BuildIsloadingOrError(snapshot);
          }
          return Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.050),


                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'About Accommodation',
                      ),
                      initialValue: _aboutAccom ?? '',
                      onChanged: (value) => _aboutAccom = value,
                      validator: (value) {
                        if (value == null) {
                          setState(() {});
                          return 'Filed required';
                        } else if (value.length < 30) {
                          return 'Please say more about Accommodation';
                        }
                        return null;
                      },
                      maxLines: null,
                      minLines: 1,
                    ),

                    sizedBoxHeight,
                    sizedBoxHeight,

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'About Payments',
                      ),
                      initialValue: _aboutPayment ?? '',
                      onChanged: (value) => _aboutPayment = value,
                      validator: (value) {
                        if (value == null) {
                          setState(() {});
                          return 'Filed required';
                        } else if (value.length < 30) {
                          return 'Please say more about payments';
                        }
                        return null;
                      },
                      maxLines: null,
                      minLines: 1,
                    ),

                    sizedBoxHeight,
                    sizedBoxHeight,

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Single room price',
                      ),
                      initialValue: _singleRoomPrice.toString() ?? '',
                      onChanged: (value) =>
                          _singleRoomPrice = double.tryParse(value) ?? 0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        } else if (!RegExp(
                          r'^[0-9]*\.?[0-9]+$',
                        ).hasMatch(value)) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),

                    sizedBoxWidth,
                    sizedBoxWidth,

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Double room price',
                        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      initialValue: _doubleRoomPrice.toString() ?? '',
                      onChanged: (value) =>
                          _doubleRoomPrice = double.tryParse(value) ?? 0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        } else if (!RegExp(
                          r'^[0-9]*\.?[0-9]+$',
                        ).hasMatch(value)) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),

                    sizedBoxWidth,
                    sizedBoxWidth,

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mobile number. eg: 081 2222 232',
                        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      initialValue: _phoneNumbers ?? '',
                      onChanged: (value) => _phoneNumbers = value,
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

                    sizedBoxHeight,
                    sizedBoxHeight,

                    DropdownButtonFormField(
                      value: Availability.contains(_availableRooms)
                          ? _availableRooms
                          : Availability.first,
                      decoration: const InputDecoration(
                        labelText: 'Available rooms',
                      ),
                      items: Availability.map((String available) {
                        return DropdownMenuItem(
                          value: available,
                          child: Text(available),
                        );
                      }).toList(),
                      onChanged: (Value) {
                        setState(() {
                          _availableRooms = Value!;
                        });
                      },
                    ),

                    sizedBoxHeight,
                    sizedBoxHeight,

                    Container(
                      decoration: border10,
                      child: SwitchListTile(
                        title: const Text(
                          "Fully Occupied",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Toggling on the switch will hide this accommodation from students',
                          style: TextStyle(color: Colors.grey),
                        ),

                        value: _isFull,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFull = value!;
                          });
                        },
                      ),
                    ),
                     SizedBox(height: SizeConfig.screenHeight * 0.025),

                    customCard1(
                      colorr: Colors.grey,
                      widgett: ListTile(
                        leading: Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                        ),
                        title: Text(
                          'LOG OUT',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.black),
                        ),
                        onTap: () async {
                          LoggingOut.showLogout(context);

                        },
                      ),
                    )
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

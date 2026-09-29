import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/my_listing.dart';
import '../../Constants/constants.dart';
import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/for_press/confirm_dialog.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../firebase_Set/set_listing.dart';
import '../../models/listing_model.dart';
import '../../static/utils.dart';
import '../../user_interface/common/settings.dart';

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

  bool _hasChanged = false;
  int? _singleRoomPrice;
  int? _doubleRoomPrice;
  String? _phoneNumbers;
  bool _isFull = false;
  String? _selectedGenders;
  String? _selectedType;
  String? _availableRooms;
  String? _aboutPayment;
  String? _aboutAccom;
  late String _selectedUni;

  late Stream<Listing_model> _listingStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listingStream = Listing().currentUserListing(
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
      _selectedUni = instance.targetInstitution;
    });
  }

  //--------------------UPDATE METHOD--------------------------------------------

  Future<void> _updateUserProfile() async {
    //  Ensure dialog is closed if this function is called from the dialog.
    if (ModalRoute.of(context)?.isCurrent == false) {
      Navigator.pop(context); // Close the AlertDialog first
    }

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
          'availableRooms': _availableRooms,
          'targetInstitution': _selectedUni,

        });
        if (mounted) {
          CustomSnackbar.show(context, 'Updated');

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyListing()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(context, 'Failed to update,try again later');
        }
      }
    }
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
    SizeConfig.init(context);

    final theme = Theme.of(context).textTheme;
    final SizedBox sizedBoxHeight = SizedBox(
      height: SizeConfig.screenHeight * 0.010,
    );
    final SizedBox sizedBoxWidth = SizedBox(
      width: SizeConfig.screenWidth * 0.010,
    );

    return PopScope(
      canPop: !_hasChanged,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Pop succeeded (because _hasChanges was false)
        if (!mounted) return;

        // --- Pop was blocked (changes exist) ---

        // 1. Show the confirmation dialog
        final action = await showUnsavedChangesDialog(
          context: context,
          onSave: () => _updateUserProfile(),
          titleStyle: theme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          buttonStyle: theme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        );

        // 2. Act based on the user's choice from the dialog
        if (!mounted) return;

        if (action == 'DISCARD') {
          // User chose to discard -> Manually pop the current screen (goes to MyProducts)
          Navigator.of(context).pop();
        } else if (action == 'SAVE') {
          // User chose to save -> Call the save function which uses pushReplacement
          _updateUserProfile();
        }
        // If action is 'CANCEL' or null, the dialog closes, and the user remains on the EditProduct screen.
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: blue900,
          automaticallyImplyLeading: false,

          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settingss()),
              );
            },
            icon: Icon(CupertinoIcons.settings, color: Colors.white, size: 25),
          ),

          actions: [
            TextButton(
              onPressed: () {
                CustomDialog.showLoading(context, 'Updating...');
                _updateUserProfile();
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                'SAVE',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                        onChanged: (value) {
                          _aboutAccom = value;
                          _markAsDirty();
                        },
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
                        onChanged: (value) {
                          setState(() {
                            _aboutPayment = value;
                            _markAsDirty();
                          });
                        },
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
                        onChanged: (value) {
                          _singleRoomPrice = int.tryParse(value) ?? 0;
                          _markAsDirty();
                        },
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
                        onChanged: (value) {
                          setState(() {
                            _doubleRoomPrice = int.tryParse(value) ?? 0;
                            _markAsDirty();
                          });
                        },
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
                          labelText: 'Mobile number',
                          //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        initialValue: _phoneNumbers ?? '',
                        onChanged: (value) {
                          setState(() {
                            _phoneNumbers = value;
                            _markAsDirty();
                          });
                        },
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
                        initialValue: Availability.contains(_availableRooms)
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
                            _markAsDirty();
                          });
                        },
                      ),

                      sizedBoxHeight,
                      sizedBoxHeight,

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
                              _markAsDirty();
                            });
                          },
                        ),
                      ),
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

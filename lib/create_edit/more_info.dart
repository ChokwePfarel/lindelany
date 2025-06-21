/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Constants/Constants.dart';
import '../Constants/Lists.dart';
import '../custom_made/widgets/colums.dart';
import '../custom_made/widgets/editableFiled.dart';
import '../methods_Funtions/check_netwok.dart';

class MoreInformation extends StatefulWidget {
  const MoreInformation({super.key});

  @override
  State<MoreInformation> createState() => _MoreInformationState();
}

class _MoreInformationState extends State<MoreInformation> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = '';
  String surName = '';
  String city = '';
  String postalCode = '';
  String phoneNumber = '';
  String idNumber = '';
  String streetAddress = '';
  String _selectedProvince = provinces.first;

  *//*final List<String> provinces = [
    'Limpopo', 'Gauteng', 'Western Cape', 'Eastern Cape', 'Mpumalanga',
    'Free State', 'KwaZulu-Natal', 'North West', 'Northern Cape'
  ];*//*

  Future<void> _showEditDialog({
    required String fieldName,
    required String initialValue,
    required Function(String) onSave,
    required String hintText,
    required String? Function(String?) validator,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: hintText),
              validator: validator,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onSave(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProfile() async {
    //This method is shot but i will use a different validation strategy on cerateAccm to improve my skils
    if (name.isEmpty ||
        surName.isEmpty ||
        city.isEmpty ||
        postalCode.isEmpty ||
        phoneNumber.isEmpty ||
        idNumber.isEmpty ||
        streetAddress.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please complete all fields")));
      return;
    }

    try {
      await _reference.doc(_auth.currentUser!.uid).update({
        'Name': name,
        'Surname': surName,
        'City': city,
        'Postal Code': postalCode,
        'Phone Number': phoneNumber,
        'ID Number': idNumber,
        'Street Address': streetAddress,
        'Province': _selectedProvince,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Information saved')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving information')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,
        title: Text('Personal Info',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () async {
              bool isConnected = await checkNetworkAndShowSnackbar(context);

              if (isConnected) {
                await _updateUserProfile();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: Row(
              children: [
                Text(
                  'Save',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_right, color: Colors.white),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),

            // Personal Details
            customCard1(
              colorr: Colors.grey,
              widgett: Column(
                children: [
                  //_buildEditableTile('Name', name, (val) => name = val, 'Enter your name', _requiredValidator),
                  buildEdditable(
                      title: 'Name',
                      value: name,
                      onSave: (val) => setState(() {
                            name = val;
                          }),
                      hintText: 'Enter your name',
                      validator: _requiredValidator),
                  //_buildEditableTile('Surname', surName, (val) => surName = val, 'Enter your surname', _requiredValidator),
                  buildEdditable(
                      title: 'Surname',
                      value: surName,
                      onSave: (val) => setState(() {
                            surName = val;
                          }),
                      hintText: 'Enter your surname',
                      validator: _requiredValidator),

                  //_buildEditableTile('ID Number', idNumber, (val) => idNumber = val, 'Enter 13-digit ID number', _idValidator),
                  buildEdditable(
                      title: 'ID Number',
                      value: idNumber,
                      onSave: (val) => setState(() {
                            idNumber = val;
                          }),
                      hintText: 'Enter 13-digit ID number',
                      validator: _idValidator),
                ],
              ),
            ),

            boxx,

            // Contact Details
            customCard1(
              colorr: Colors.grey,
              widgett: Column(
                children: [
                  buildEdditable(
                      title: 'Private Phone Number',
                      value: phoneNumber,
                      onSave: (val) => setState(() {
                            phoneNumber = val;
                          }),
                      hintText: '081...',
                      validator: _phoneValidator),

                  //_buildEditableTile('Phone Number', phoneNumber, (val) => phoneNumber = val, '081...', _phoneValidator),
                  buildEdditable(
                      title: 'Postal Code',
                      value: postalCode,
                      onSave: (val) => setState(() {
                            postalCode = val;
                          }),
                      hintText: 'Enter your postal code',
                      validator: _requiredValidator),
                  buildEdditable(
                      title: 'City',
                      value: city,
                      onSave: (val) => setState(() {
                            city = val;
                          }),
                      hintText: 'Enter your city',
                      validator: _requiredValidator)

                  // _buildEditableTile('City', city, (val) => city = val, 'Enter your city', _requiredValidator),
                  // _buildEditableTile('Postal Code', postalCode, (val) => postalCode = val, 'Enter your postal code', _requiredValidator),
                  // buildEdditable(title:'Postal Code', value: postalCode, onSave: (val) => postalCode = val, hintText: 'Enter your postal code', validator: _requiredValidator)
                ],
              ),
            ),

            boxx,

            // Address
            customCard1(
              colorr: Colors.grey,
              widgett: Column(
                children: [
                  buildEdditable(
                      title: 'Street Address',
                      value: streetAddress,
                      onSave: (val) => setState(() {
                            streetAddress = val;
                          }),
                      hintText: 'Enter your street address',
                      validator: _requiredValidator),
                  //_buildEditableTile('Street Address', streetAddress, (val) => streetAddress = val, 'Enter your street address', _requiredValidator),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      decoration: const InputDecoration(labelText: 'Province'),
                      items: provinces.map((province) {
                        return DropdownMenuItem(
                            value: province, child: Text(province));
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTile(
    String title,
    String value,
    Function(String) onSave,
    String hintText,
    String? Function(String?) validator,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(value.isEmpty ? 'Not set' : value),
          trailing: Icon(
              value.isEmpty ? Icons.arrow_forward_ios_rounded : Icons.edit,
              color: blue900),
          onTap: () => _showEditDialog(
            fieldName: title,
            initialValue: value,
            onSave: (newValue) => setState(() => onSave(newValue)),
            hintText: hintText,
            validator: validator,
          ),
        ),
        const Divider(),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    return (value == null || value.trim().isEmpty)
        ? 'This field is required'
        : null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';
    if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _idValidator(String? value) {
    if (value == null || value.isEmpty) return 'ID required';
    if (value.length != 13 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Enter a valid 13-digit ID number';
    }
    return null;
  }
}*/

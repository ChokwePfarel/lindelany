import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/constants/scale.dart';

import '../../Constants/constants.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/editableFiled.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../static/snackbar.dart';
import '../../user_interface/common/settings.dart';

class EditVehicle extends StatefulWidget {
  const EditVehicle({super.key});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _reference = FirebaseFirestore.instance;

final _FormKey = GlobalKey<FormState>();

String _numbers = '';

class _EditVehicleState extends State<EditVehicle> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    Future<void> update() async {
      try {
        await _reference
            .collection('Vehicle')
            .doc(_auth.currentUser!.uid)
            .update({'numbers': _numbers});
        CustomSnackbar.show(context, 'Updated Successfully');
        Navigator.pop(context);
      } catch (e) {
//        //         print(e.toString());
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blue900,

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
            onPressed: () async {
              final bool isConnected = await checkNetworkAndShowSnackbar(
                context,
              );
              if (isConnected) {
                if (_FormKey.currentState!.validate()) {
                  update();
                }
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

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _FormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.030),

              customCard1(
                colorr: Colors.grey,
                widgett: buildEdditable(
                  title: 'New Phone Numbers',
                  value: _numbers,
                  onSave: (val) => setState(() {
                    _numbers = val;
                  }),
                  hintText: '081...',
                  validator: _requiredValidator,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

}

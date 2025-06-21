import 'package:flutter/material.dart';
import '../../methods_Funtions/doc_check.dart';
import '../create/create_vehicle.dart';


class createOrFill extends StatefulWidget {
  const createOrFill({super.key});

  @override
  State<createOrFill> createState() => _createOrFillState();
}

class _createOrFillState extends State<createOrFill> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: docCheck(
        onTrue: Vehicle(),
    onFalse: Vehicle(), //MoreInformation(),
    useNavigation: true,
    ));
  }
}

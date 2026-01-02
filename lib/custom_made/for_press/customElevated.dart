import 'package:flutter/material.dart';

import '../../Constants/constants.dart';

class customElevated extends StatelessWidget {
  final Widget nextPage;
  final String LabelText;
  final Color? color;

  const customElevated({
    super.key,
    required this.nextPage,
    required this.LabelText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        child: Text(
          LabelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//--------------------------------------------------------------------------------

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class customAppBar extends StatelessWidget {
  final String text;
  const customAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {

  return AppBar(
    leading: IconButton(onPressed: (){
      Navigator.pop(context);
    }, icon: const Icon(CupertinoIcons.arrow_left,color: Colors.white,)),

    title: Text(text,style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 17
    ),),
  );


  }
}

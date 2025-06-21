import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


//-------------------------------------------------------------------Small text

class customText extends StatelessWidget {
  final String text;
  const customText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.normal,)
    );
  }
}


//-----------------------------------------------------------------------Heading

class customTextHeading extends StatelessWidget {
  final String text;
  const customTextHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
    style: Theme.of(context).textTheme.bodyMedium

      /*GoogleFonts.poppins(
      fontSize: 20,
          color: Colors.black87
        ,
          fontWeight: FontWeight.bold
    )*/);
  }
}
class customTextHeadingWhite extends StatelessWidget {
  final String text;
  const customTextHeadingWhite({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
    style: GoogleFonts.poppins(
      fontSize: 20,
          color: Colors.white
        ,
          fontWeight: FontWeight.bold
    ));
  }
}


//----------------------------------------------------------------customTextCard

class customTextCard extends StatelessWidget {
   final String text;
  const customTextCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.poppins(
        fontSize: 17,
            color: Colors.white,
        fontWeight: FontWeight.bold
      ));
  }
}

class customTextCardBlack extends StatelessWidget {
  final bool isGrey;
  final String text;
  const customTextCardBlack({super.key, required this.text, this.isGrey = false});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.poppins(
        fontSize: 15,
            color: isGrey? Colors.grey : Colors.black87,
        fontWeight: FontWeight.bold
      ));
  }
}



class customTextSub extends StatelessWidget {
   final String text;
  const customTextSub({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.poppins(
        fontSize: 15,
            color: Colors.black87,
        fontWeight: FontWeight.bold
      ));
  }
}


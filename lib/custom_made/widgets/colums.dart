import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/scale.dart';

class customColums extends StatelessWidget {
  final String text;
  final String textt;
  const customColums({super.key, required this.text, required this.textt});

  @override
  Widget build(BuildContext context) {


    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;
    final screenWidth = SizeConfig.screenWidth;


    return Container(
      width: screenWidth * 0.45,
      decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(textt,style: GoogleFonts.poppins(
                color: Colors.white
            ),),
          SizedBox(height: hightTen),
            Text(text,
              style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              ),)
          ],
        ),
      ),
    );
  }
}

class iconBox extends StatelessWidget {
  final IconData IIcon;
  final String  textt;
  const iconBox({super.key, required this.IIcon, required this.textt});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    return GestureDetector(
      onLongPress: () {
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: 300,
            //bottom: 200,
            left: 100,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Text(textt, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );

        overlay.insert(overlayEntry);

        // Remove after 2 seconds
        Future.delayed(Duration(seconds: 2), () => overlayEntry.remove());
      },
      child: Container(
        height: screenHeight * 0.052,
        width: screenWidth * 0.104,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey,
        ),

        child: Icon(IIcon,size: 30,color: Colors.blue.shade900,),
      ),
    );
  }
}





class customCard1 extends StatelessWidget {
  final Widget widgett;
  final Color? colorr;
  final double? heightt;
  final EdgeInsets? isPadding;
  const customCard1({super.key, required this.widgett,this.colorr,this.heightt,this.isPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightt,
        width: double.infinity,
        decoration: BoxDecoration(
            color: colorr ?? Colors.white,
            borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
        padding: isPadding ?? EdgeInsets.all(8.0),
    child: widgett));
  }
}

class customCardForTextInput extends StatelessWidget {
  final Widget someWidget;

  const customCardForTextInput({super.key, required this.someWidget});

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: someWidget,
    );
  }
}



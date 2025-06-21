import 'package:flutter/material.dart';

import '../../Constants/Constants.dart';




class customElevated extends StatelessWidget {
  final Widget nextPage;
  final String LabelText;
  final double widthh;

  const customElevated(
      {super.key, required this.nextPage, required this.LabelText, required this.widthh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthh,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: blue900,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          onPressed: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=> nextPage));
          },
          child: Text(LabelText,
            style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),)),
    );
  }
}

class customElevatedWithNoPush extends StatelessWidget {
  final Widget nextPage;
  final String LabelText;
  final double widthh;

  const customElevatedWithNoPush(
      {super.key, required this.nextPage, required this.LabelText, required this.widthh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthh,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: blue900,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          onPressed: () {

          },
          child: Text(LabelText,
            style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),)),
    );
  }
}

//--------------------------------------------------------------------------------

class sizedElevatedIcon extends StatelessWidget {
  final Widget nextPag;
  final double Widthh;
  final IconData iicon;


  const sizedElevatedIcon(
      {super.key, required this.nextPag, required this.Widthh, required this.iicon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Widthh,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: blue900,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => nextPag));
          },
          child: Icon(iicon,color: Colors.white,)),
    );
  }
}




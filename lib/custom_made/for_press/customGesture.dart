import 'package:flutter/material.dart';

class customGesture extends StatelessWidget {
  final Widget nextPage;
  final Widget childd;
  const customGesture({super.key,
  required this.nextPage,
  required this.childd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> nextPage));
      },
      child: childd,

    );
  }
}

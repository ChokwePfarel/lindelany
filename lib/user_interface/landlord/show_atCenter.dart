import 'package:flutter/material.dart';

import '../../Constants/Constants.dart';


class showAtCenter extends StatelessWidget {
  final String imagesUrl; //TAKES AN IMAGE AND SHOW IT AT THE CENTER
  const showAtCenter({super.key, required this.imagesUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue900,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);},
            icon: backk),
      ),
      body: Center(
        child: Image.network(imagesUrl,fit: BoxFit.contain,),
      ),
    );
  }
}

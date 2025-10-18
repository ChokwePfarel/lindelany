import 'package:flutter/material.dart';

class NetworkBanner{
  static Widget noInternet(){
    return Container(
      width: double.infinity,
      color: Colors.red.shade900,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('No network connection',
          textAlign: TextAlign.center,
          style: TextStyle(
          color: Colors.white,
          fontSize: 16,
      ),
        ),),
      );
  }
}

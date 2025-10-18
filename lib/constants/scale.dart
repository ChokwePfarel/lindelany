import 'package:flutter/cupertino.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double heightUnit;
  static late double widthUnit;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    heightUnit = screenHeight * 0.026;
    widthUnit = screenWidth * 0.026;
  }
}

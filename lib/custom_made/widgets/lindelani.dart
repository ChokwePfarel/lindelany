import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constants/Constants.dart';

class lindelani extends StatelessWidget {
  final bool isLindeWhite;
  final bool isLWhite;
  const lindelani({super.key,
  required this.isLindeWhite,
  required this.isLWhite});

  @override
  Widget build(BuildContext context) {
      const double fontSize = 35;

      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration:  BoxDecoration(
                  color: isLindeWhite ? Colors.white : blue900,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'L',
                  style: GoogleFonts.signika(
                    color: isLWhite ? blue900 : Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1, // prevent extra spacing
                  ),
                ),
              ),
            ),
            TextSpan(text: 'inde',
              style: GoogleFonts.poppins(
                color: isLindeWhite ? Colors.white : blue900,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                height: 1, // prevent extra spacing
              ),),
          ],
        ),
      );
    }}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const backk = Icon(CupertinoIcons.arrow_left, color: Colors.white);
const backk2 = Icon(CupertinoIcons.arrow_left, color: Colors.black87);

const paddingg = EdgeInsets.all(8.0);

final blue900 = Colors.blue.shade900;

final dividerWhite = Divider(color: Colors.white, height: 15);

final grey100 = Colors.grey.shade100;

final border10 = BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  color: blue900,
);

final border10White = BoxDecoration(
  borderRadius: BorderRadius.circular(10),
  color: Colors.white,
);

final divider = Divider(height: 15, color: Colors.blue.shade900);

const boxx = SizedBox(height: 10);
const boxx2 = SizedBox(width: 5);
const Dividerr = Divider();

final Poppins = GoogleFonts.poppins(
  textStyle: const TextStyle(
    fontSize: 15,
    color: Colors.black87,
    fontWeight: FontWeight.normal,
  ),
);
final secondFont = GoogleFonts.afacad(textStyle: const TextStyle(fontSize: 15));
final Iconn = Icon(Icons.check_rounded, color: Colors.green[900], size: 15);
final mainFont = GoogleFonts.aboreto(
  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
);

final headText = GoogleFonts.afacad(
  textStyle: const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
);

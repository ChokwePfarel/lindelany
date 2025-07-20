import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/transport_broadcast/userInteface/all_broadcasts.dart';
import 'package:lindelany/user_interface/Common/Accommodations.dart';
import 'package:lindelany/user_interface/landlord/myAccommodations.dart';
import 'package:provider/provider.dart';
import '../firebase_Set/user.dart';
import 'logIn.dart';

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {

  @override
  void initState(){
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUser();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserProvider>(context).user;
    print('current user type: ${user?.userType}');
    final userType = user?.userType.trim().toLowerCase();
    final isLandlord = userType == 'landlord';
    final isDriver = userType == 'transportation';


    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(isLandlord){
              return MyListing();

            } else if(isDriver){
              return const AllBroadcast();
            }
            else {
              return const Accomodations();

            }
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Gate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 60;
    return Scaffold(
      backgroundColor: Colors.blue.shade900, // Dark blue
      body: Center(
        child: RichText(
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
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'L',
                    style: GoogleFonts.signika(
                      color: Colors.blue.shade900,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      height: 1, // prevent extra spacing
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: 'inde',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1, // prevent extra spacing
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

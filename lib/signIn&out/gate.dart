import 'package:cloud_firestore/cloud_firestore.dart'; //for source
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/constants/constants.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/transport_broadcast/userInteface/all_broadcasts.dart';
import 'package:lindelany/user_interface/Common/accommodations.dart';
import 'package:lindelany/user_interface/landlord/my_listing.dart';
import 'package:provider/provider.dart';
import '../classes/user_model.dart';
import '../firebase_Set/user.dart';
import 'logIn.dart';

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  // FirebaseAuth stream
  final Stream<User?> _authStateChanges =
  FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final appUser = userProvider.user;
    final isUserLoading = userProvider.isUserLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          // 1. Firebase is still initializing the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue.shade900));
          }

          // 2. Error from auth stream
          if (snapshot.hasError) {
            return _onFail(errorMessage: 'Authentication stream error: ${snapshot.error}');
          }

          // 3. Build correct screen
          return _buildContent(snapshot.data, appUser, isUserLoading);
        },
      ),
    );
  }

  // Main content state resolver
  Widget _buildContent(
      User? firebaseUser,
      UserModel? appUser,
      bool isUserLoading,
      ) {

    //Not logged in → go to Login page
    if (firebaseUser == null) {
      if (appUser != null) {
        context.read<UserProvider>().clearUser();
      }
      return const LoginPage();
    }

    // Logged in, but still loading user data → show loader
    if (isUserLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue.shade900,));
    }

    //Logged in but user data missing even after loading , real error
    if (appUser == null) {
      return _onFail(
        errorMessage: 'User data not found. Please tap Try Again to reload data.',
      );
    }

    //Fully authenticated and user data ready
    final userType = appUser.userType.trim().toLowerCase();

    switch (userType) {
      case 'landlord':
        return const MyListing();
      case 'transportation':
        return const AllBroadcast();
      default:
        return const Accomodations();
    }
  }

  // Error screen with Try Again button
  Widget _onFail({String? errorMessage}) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      backgroundColor: blue900,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 80, color: Colors.white.withOpacity(0.9)),
                SizedBox(height: screenHeight * 0.032),

                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: screenHeight * 0.016),

                Text(
                  errorMessage ??
                      'Please close and restart the application to continue.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: screenHeight * 0.040),

                ElevatedButton(
                  onPressed: () {
                    userProvider.fetchUser(source: Source.server);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: blue900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 3), () {


        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Gate(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 60;
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
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
                        height: 1,
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
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

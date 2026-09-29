/*import 'package:cloud_firestore/cloud_firestore.dart'; //for source
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/constants/constants.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/transport_broadcast/userInteface/all_broadcasts.dart';
import 'package:lindelany/user_interface/Common/accommodations.dart';
import 'package:lindelany/user_interface/landlord/my_listing.dart';
import 'package:provider/provider.dart';
import '../firebase_Set/user.dart';
import '../models/user_model.dart';
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
  }*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Constants/Constants.dart';
import '../custom_made/widgets/animated-loader.dart';
import '../firebase_Set/user.dart';
import '../models/user_model.dart';
import '../user_interface/common/onboarding.dart';
import 'authService.dart';
import 'logIn.dart';
import '../transport_broadcast/userInteface/all_broadcasts.dart';
import '../user_interface/Common/accommodations.dart';
import '../user_interface/landlord/my_listing.dart';

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  @override
  void initState() {
    super.initState();
    // Ensure we attempt to fetch the user if the user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<UserProvider>().fetchUser();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.isSigningIn,
      builder: (context, isSigning, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                //  Seed with the current user so Gate never starts "empty"
                initialData: FirebaseAuth.instance.currentUser,
                // In Gate's StreamBuilder builder, replace the Consumer block with this:
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: CircularProgressIndicator(
                      color: blue900,
                    ));
                  }

                  if (snapshot.data == null) {
                    return const LoginPage();
                  }

                  //  Trigger fetch whenever we get a non-null user from the stream
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final provider = context.read<UserProvider>();
                    if (provider.user == null && !provider.isUserLoading) {
                      provider.fetchUser();
                    }
                  });

                  return Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      if (userProvider.isUserLoading) {

                        return  Center(child: CircularProgressIndicator(
                          color: blue900,
                        ));
                      }
                      if (userProvider.user == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        ); // wait, don't show LoginPage
                      }
                      return _routeUser(userProvider.user!);

                    },
                  );
                },
              ),
            ),

            AnimatedLoadingDialogAlt(
              isSigning: isSigning, // your boolean state
            )
          ],
        );
      },
    );
  }

  Widget _routeUser(UserModel appUser) {
    // 1. Check if the user is in a "Setup Required" state
    // Assuming your UserModel has a property that indicates if setup is needed
    // or if userType is empty for new users.
    final userType = appUser.userType.trim().toLowerCase();

    // If the userType is empty, they haven't finished setup
    if (userType.isEmpty) {
      return const GoogleUserSetupPage();
    }

    // 2. Otherwise, route based on type
    switch (userType) {
      case 'landlord':
        return const MyListing();
      case 'transportation':
        return const AllBroadcast();
      default:
        return const Accomodations();
    }
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

    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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

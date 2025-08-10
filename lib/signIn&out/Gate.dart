import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/transport_broadcast/userInteface/all_broadcasts.dart';
import 'package:lindelany/user_interface/Common/Accommodations.dart';
import 'package:lindelany/user_interface/landlord/myAccommodations.dart';
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
  late final Stream<User?> _authStateChanges;
  bool _isLoadingUser = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authStateChanges = FirebaseAuth.instance.authStateChanges();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).fetchUser();
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _errorMessage = 'Failed to load user data';
        });
      }
    }
  }

  Widget _buildContent(User? firebaseUser, UserModel? appUser) {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeUser,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (firebaseUser == null) {
      return const LoginPage();
    }

    if (appUser == null) {
      return const Center(child: Text('User data not available'));
    }

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Auth error: ${snapshot.error}'));
          }
          return _buildContent(snapshot.data, user);
        },
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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Gate(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
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
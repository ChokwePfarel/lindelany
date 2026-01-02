import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lindelany/payments/plans.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/scale.dart';
import '../signIn&out/gate.dart';
import '../static/snackbar.dart';

class YocoWebView extends StatefulWidget {
  final SubscriptionPlan plan;
  final String collection;
  final String docId;

  const YocoWebView({
    super.key,
    required this.plan,
    required this.collection,
    required this.docId,
  });

  @override
  State<YocoWebView> createState() => _YocoWebViewState();
}

class _YocoWebViewState extends State<YocoWebView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startYocoCheckout();
  }

  Future<void> _startYocoCheckout() async {
    const String firebaseFunctionUrl =
        'https://createyococheckout-7m47tt22sa-uc.a.run.app';
    String userId = _auth.currentUser!.uid;
    try {
      final response = await http.post(
        Uri.parse(firebaseFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amountInCents': (widget.plan.price * 100).toInt(),
          'collectionName': widget.collection,
          'docId': widget.docId,
          'planName': widget.plan.name,
          'planPrice': widget.plan.price,
          'planDurationMonths': widget.plan.durationMonths,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String redirectUrl = data['redirectUrl'];
        await _launchUrlInCustomTab(redirectUrl);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Gate()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        CustomSnackbar.show(context, 'Failed to create Yoco checkout.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      CustomSnackbar.show(context, 'An error occurred.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _launchUrlInCustomTab(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (e) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1), // darker blue
              Color(0xFF1565C0), // lighter blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated circular progress with pulsing background
              SizedBox(
                width: SizeConfig.screenWidth * 0.10,
                height: SizeConfig.screenHeight * 0.10,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing effect
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Container(
                          width: 80 * value,
                          height: 80 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2 * (1 - value)),
                          ),
                        );
                      },
                      onEnd: () {}, // keeps it smooth
                    ),
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ),

               SizedBox(height: SizeConfig.screenHeight * 0.024),

              // Main animated text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 600),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                child: const Text('Redirecting to YOCO ...'),
              ),

              SizedBox(height: SizeConfig.screenHeight  *0.012),

              // Subtitle
              Text(
                'Please wait',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

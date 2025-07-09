import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoNetworkBanner extends StatefulWidget {
  const NoNetworkBanner({super.key});

  @override
  _NoNetworkBannerState createState() => _NoNetworkBannerState();
}

class _NoNetworkBannerState extends State<NoNetworkBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isOffline ? 50 : 0,
      color: Colors.red,
      child: Center(
        child: Text(
          "No Internet Connection,changes wont be saved",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

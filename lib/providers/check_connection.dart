import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _isConnected = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }
}

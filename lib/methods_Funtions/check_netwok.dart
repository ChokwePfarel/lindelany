import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/static/snackbar.dart';

Future<bool> checkNetworkAndShowSnackbar(BuildContext context) async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
      CustomSnackbar.show(context, 'No internet connection');

    return false;
  }
  return true;
}

Future<bool> hasNetworkConnection() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

Future<bool> checkNetworkAndShowUI(BuildContext context) async {
  final isConnected = await hasNetworkConnection();
  if (!isConnected) {
    // The UI will be handled by the consumer widget
    return false;
  }
  return true;
}
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

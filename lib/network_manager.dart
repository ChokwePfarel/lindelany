import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class NetworkManager {
  static void monitorNetwork() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        // No connection, so use cache
        FirebaseFirestore.instance.disableNetwork().then((_) {
          print('Offline, using cache data');
        });
      } else {
        // Connection available, use live data
        FirebaseFirestore.instance.enableNetwork().then((_) {
          print('Online, using live data');
        });
      }
    });
  }
}


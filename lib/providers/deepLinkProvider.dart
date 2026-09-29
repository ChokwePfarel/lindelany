import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkProvider with ChangeNotifier {
  Uri? _pendingDeepLinkUri;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Uri? get pendingDeepLinkUri => _pendingDeepLinkUri;

  void initAppLinks() {
//    debugPrint(' DeepLinkProvider: Initializing app links...');

    // Handle the initial link if app was opened via deep link
    _handleInitialLink();

    // Handle links while app is running
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();

      if (uri != null) {


        _pendingDeepLinkUri = uri;
        notifyListeners();
      } else {
      }
    } catch (e) {
    }
  }

  void _handleIncomingLinks() {

    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {


        _pendingDeepLinkUri = uri;
        notifyListeners();
      },
      onError: (err) {
      },
    );

  }

  void clearPendingDeepLink() {
    _pendingDeepLinkUri = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}

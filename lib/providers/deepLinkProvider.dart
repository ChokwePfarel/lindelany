import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkProvider with ChangeNotifier {
  Uri? _pendingDeepLinkUri;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Uri? get pendingDeepLinkUri => _pendingDeepLinkUri;

  void initAppLinks() {
//    debugPrint('🔗 DeepLinkProvider: Initializing app links...');

    // Handle the initial link if app was opened via deep link
    _handleInitialLink();

    // Handle links while app is running
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
//      debugPrint('🔗 Checking for initial deep link...');
      final uri = await _appLinks.getInitialLink();

      if (uri != null) {
//        debugPrint('✅ Initial deep link detected!');
//        debugPrint('🔗 Full URI: ${uri.toString()}');
//        debugPrint('🔗 Scheme: ${uri.scheme}');
//        debugPrint('🔗 Host: ${uri.host}');
//        debugPrint('🔗 Path: ${uri.path}');
//        debugPrint('🔗 Query params: ${uri.queryParameters}');

        _pendingDeepLinkUri = uri;
        notifyListeners();
      } else {
//        debugPrint('ℹ️ No initial deep link found (app opened normally)');
      }
    } catch (e) {
//      debugPrint('❌ Error getting initial link: $e');
    }
  }

  void _handleIncomingLinks() {
//    debugPrint('🔗 Setting up incoming link listener...');

    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
//        debugPrint('✅ Incoming deep link detected!');
//        debugPrint('🔗 Full URI: ${uri.toString()}');
//        debugPrint('🔗 Scheme: ${uri.scheme}');
//        debugPrint('🔗 Host: ${uri.host}');
//        debugPrint('🔗 Path: ${uri.path}');
//        debugPrint('🔗 Query params: ${uri.queryParameters}');

        _pendingDeepLinkUri = uri;
        notifyListeners();
      },
      onError: (err) {
//        debugPrint('❌ Error listening to deep links: $err');
      },
    );

//    debugPrint('✅ Incoming link listener setup complete');
  }

  void clearPendingDeepLink() {
//    debugPrint('🔗 Clearing pending deep link');
    _pendingDeepLinkUri = null;
    notifyListeners();
  }

  @override
  void dispose() {
//    debugPrint('🔗 DeepLinkProvider: Disposing...');
    _linkSubscription?.cancel();
    super.dispose();
  }
}

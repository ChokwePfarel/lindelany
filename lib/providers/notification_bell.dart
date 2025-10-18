import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasNewMessages = false;

  bool get hasNewMessages => _hasNewMessages;

  void setNewMessages(bool value) {
    _hasNewMessages = value;
    notifyListeners();
  }
}

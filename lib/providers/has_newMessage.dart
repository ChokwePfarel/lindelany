import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class HasNewMessage extends ChangeNotifier{


  bool _hasNewMessage = true;

  bool get hasNewMessage => _hasNewMessage;

  void updateHasNewMessage(bool status){

    if(_hasNewMessage != status){
      _hasNewMessage = status;
      notifyListeners();
    }

  }
}


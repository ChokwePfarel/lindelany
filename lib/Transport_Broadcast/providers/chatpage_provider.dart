
import 'package:flutter/material.dart';

import '../../classes/user_model.dart';
import '../../user_interface/Common/chat_page.dart';
import '../broadcast_vehicle_model.dart';

class chatprovider2 extends ChangeNotifier{
  late UserModel _user;
  late vehicleModel _vehicle;

  UserModel get user => _user;
  //vehicleModel get vehicle => _vehicle;

  void setChatDetails(UserModel user){
    _user = user;
   // _vehicle = vehicle;
    notifyListeners();
  }

  void navigate2chat(BuildContext context,UserModel user,){
    setChatDetails(user,);
    Navigator.push(context,
    MaterialPageRoute(
        builder: (context)=> Chatpage()));
  }

}

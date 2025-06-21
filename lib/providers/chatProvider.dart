import 'package:flutter/material.dart';
import '../classes/listing_model.dart';
import '../classes/student_model.dart';
import '../classes/user_model.dart';
import '../user_interface/Common/chat_page.dart';


class chatProvider extends ChangeNotifier{
    late UserModel _selectedUser;
    late StudentModel _selectedStudent;
    late Listing_model _selectedHouse;

    UserModel get selectedUser => _selectedUser;
    StudentModel get selectedStudent => _selectedStudent;
    Listing_model get selectedHouse => _selectedHouse;


    //CALLED EVERYTIME WHEN NAVIGATION IS REQUIRED

    void setChatDetails(UserModel user){
      _selectedUser = user;
     // _selectedStudent = student;

     // _selectedHouse= house;
      notifyListeners();
    }

     navigateToChat(BuildContext context, UserModel user, ) {
      setChatDetails(user); // Set details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Chatpage(),
        ),
      );
    }
}

import 'package:flutter/material.dart';


class utils{
  static String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

class AsyncUtils {
  static bool isLoadingOrError<T> (AsyncSnapshot snapshot){
    //possibilities
    return snapshot.connectionState == ConnectionState.waiting
        || snapshot.hasError || !snapshot.hasData;
  }

  static Widget BuildIsloadingOrError<T>(AsyncSnapshot<T> snapshot){

    if(snapshot.connectionState == ConnectionState.waiting){
      return Center(child: CircularProgressIndicator(),);
    }
    if(snapshot.hasError){
      return Center(child: Text('Error ${snapshot.error}'),);
    }

    return Center(child: Text('No data available',style: TextStyle(
        color: Colors.black
    ),),);
  }
}

class currentUserType{
  final String usertype;
  currentUserType(this.usertype,);

}


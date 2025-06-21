import 'package:flutter/material.dart';

class AsyncUtils {

  //static so i can acces withoght creating an sintance of the class
  static bool isLoadingOrError<T> (AsyncSnapshot snapshot){
    //possibilities
    return snapshot.connectionState == ConnectionState.waiting
      || snapshot.hasError || !snapshot.hasData;
  }

  //Wideget
static Widget BuildIsloadingOrError<T>(AsyncSnapshot<T> snapshot){

    if(snapshot.connectionState == ConnectionState.waiting){
      return Center(child: CircularProgressIndicator(),);
    }
    if(snapshot.hasError){
      return Center(child: Text('Error ${snapshot.error}'),);
    }
    //otherwise if snapshot has no data
  return Center(child: Text('No data available'),);
}
}

class studentDocCheck{

  final bool existance;

  studentDocCheck(this.existance);

}

class driverDocCheck{

  final bool existance;

  driverDocCheck(this.existance);

}

class currentUserType{
  final String usertype;
  currentUserType(this.usertype,);

}

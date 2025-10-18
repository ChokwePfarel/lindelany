import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomNavigation{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

 /* Future<void> navigateBasedOnUserDoc(BuildContext context, String userId, Widget truePage,Widget otherPage, String collectionName) async {

    try{
      showDialog(
          context: context,
          builder: (context)=> const Center(child: CircularProgressIndicator(),));

      DocumentSnapshot userDoc = await _reference.collection(collectionName).doc(userId)
      .get(const GetOptions(source: Source.cache));

      if(!userDoc.exists){
         userDoc = await _reference.collection(collectionName).doc(userId)
            .get(const GetOptions(source: Source.server));
      }
  //CLOSE THE INDICATOR
      Navigator.of(context).pop();

      if (userDoc.exists) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => truePage));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => otherPage));

      }
    }catch (e){
//       print(e.toString());
    }
  }


  Future<void> navigateBasedOnUserDocAndUserType(BuildContext context, String userId, Widget truePage, String collectionName) async {
    DocumentSnapshot userDoc = await _reference.collection(collectionName).doc(userId).get();
    if (userDoc.exists) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => truePage));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Create a profile")));
    }
  }
*/


  //CHECK IS A DOCUMENT EXISTS
Future<bool> getDocumentBool(String collection) async{

  String userId = _auth.currentUser!.uid;

    try{

      DocumentSnapshot doc = await _reference.collection(collection).doc(userId).get();

      bool existance = doc.exists;

//       print('Documents found $existance');

      return existance;


    } catch (e){
//       print('Error while checking for document $e');
    } return false;

}


//CHECK IF A FLAG/FILED EXIST
  ///FutureBuilder is used for handling a single asynchronous operation that returns a future.
  ///It rebuilds the widget once when the future completes.
  ///It's ideal for scenarios where you want to perform an operation once and
  ///then update the UI with the result.

  /*Future<bool> checkForDoc(String collection,String field) async {
    String userId = _auth.currentUser!.uid;
    try{
      DocumentSnapshot doc =await _reference.collection(collection).doc(userId).get();

      final data = doc.data() as Map<String, dynamic>;

       bool exist = doc.exists && data[field] != null;

//        print('Document exist? : $exist');

       return exist;

     } catch (e) {
//       print('Error on checkDoc $e');
     return false;
    }
  }*/

 /* Future<String> CurrentUserType() async {
    try{
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot doc =await _reference.collection('Users').doc(userId).get();

      final data = doc.data() as Map<String, dynamic>;

       String userType = data['UserType'] ;

//        print('Document exist? : $userType');

       return userType;

     } catch (e) {
//       print('Error on checkDoc $e');
     return '';
    }
  }*/

}


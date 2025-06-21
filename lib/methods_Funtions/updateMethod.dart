
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _reference = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;


Future<void> updateStatus(String otherUserId, String status,String messageID) async {

  String currentUserID = _auth.currentUser!.uid ?? '';

  List ids = [currentUserID,otherUserId];
  ids.sort();
  String chatRoomID = ids.join('_');

  try{
  await _reference.collection("chatRoomIds").doc(chatRoomID).collection("messages").
  doc(messageID).update({
    'status': status
  });

  print('Message status updated to $status');}
      catch (e) {
        print('Message status failed to updated to $status');
      }
}

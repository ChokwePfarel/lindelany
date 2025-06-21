/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../classes/user_model.dart';



class TextedUser {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _reference = FirebaseFirestore.instance;

  Stream<List<UserModel>> getContactedUsersStream() {
    final currentUserId = _auth.currentUser!.uid;

    return _reference.collection("chatRoomIds")
        .where("participants", arrayContains: currentUserId)
        .snapshots()
        .asyncMap((chatRoomSnapshot) async {
      Set<String> contactedUserIds = {};

      // Iterate through chat rooms to collect contacted user IDs
      for (var doc in chatRoomSnapshot.docs) {
        List<dynamic> participants = doc['participants'];

        // Add all participants except the current user to the set
        for (String userId in participants) {
          if (userId != currentUserId) {
            contactedUserIds.add(userId);
          }
        }
      }

      List<UserModel> contactedUsers = []; // 🔄 Updated list type

      for (String userId in contactedUserIds) {
        var userDoc = await _reference.collection("Users").doc(userId).get();
        if (userDoc.exists) {
          // Get chatRoomId by sorting both IDs
          List<String> ids = [currentUserId, userId];
          ids.sort();
          String chatRoomId = ids.join('_');

          // Get the latest message
          var latestMessageSnapshot = await _reference
              .collection("chatRoomIds")
              .doc(chatRoomId)
              .collection("messages")
              .orderBy('timeStamp', descending: true)
              .limit(1)
              .get();

          final latestMessageDoc = latestMessageSnapshot.docs.isNotEmpty
              ? latestMessageSnapshot.docs.first
              : null;

          // Convert user doc
          final user = UserModel.fromDocument(userDoc);

          // Create updated user with latest message timestamp
          final userWithTimestamp = UserModel(
            userId: user.userId,
            userName: user.userName,
            userType: user.userType,
            userGender: user.userGender,
            profilePictureUrl: user.profilePictureUrl,
            hasPaid: user.hasPaid,
            paymentHistory: [...user.paymentHistory],
            latestMessageTimestamp: latestMessageDoc != null
                ? (latestMessageDoc['timeStamp'] as Timestamp).toDate()
                : DateTime.fromMillisecondsSinceEpoch(0), // fallback
          );

          contactedUsers.add(userWithTimestamp);
        }
      }


      // Sort the list by latest message timestamp (most recent first)
      contactedUsers.sort((a, b) => b.latestMessageTimestamp.compareTo(a.latestMessageTimestamp));

      // Print debug information
      print("Contacted Users: ${contactedUsers.map((user) => user.userName).toList()}");

      return contactedUsers;
    });
  }
}
*/


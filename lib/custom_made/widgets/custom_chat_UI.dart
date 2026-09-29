import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Constants/Constants.dart';
import '../../methods_functions/chatService.dart';
import '../../models/message_model.dart';


class CustomMessage extends StatefulWidget {
  final MessageModel message;
  final String chatRoomId;


  const CustomMessage(this.message, this.chatRoomId, {super.key});

  @override
  State<CustomMessage> createState() => _CustomMessageState();
}

class _CustomMessageState extends State<CustomMessage> {
  final ChatServices _chatServices = ChatServices();

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      case 'queued':
      default:
        return Icons.access_time;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'sent':
        return Colors.blue;
      case 'read':
        return Colors.green;
      case 'queued':
      default:
        return Colors.grey;
    }
  }

  // Format the timestamp
  String formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Future _deleteDialog() async {
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        content: TextButton(onPressed: ()async {
          Navigator.pop(context);

          await _chatServices.deleteMessage(widget.chatRoomId, widget.message.messageId);

        }, child: Text('Delete Message',style: TextStyle(color: blue900),)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the message is sent by the current user
    final isMe =
        FirebaseAuth.instance.currentUser!.uid == widget.message.senderId;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.7, // Limit bubble width
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueGrey.shade900 : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: GestureDetector(
              onLongPress: isMe ? _deleteDialog : null,
              child: Text(
                widget.message.message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Timestamp and Status Icon
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timestamp
                Text(
                  formatTimestamp(widget.message.timeStamp),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),

                const SizedBox(width: 4), // Spacing between time and icon

                isMe
                    ? Icon(
                        getStatusIcon(widget.message.status),
                        size: 12,
                        color: getStatusColor(widget.message.status),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

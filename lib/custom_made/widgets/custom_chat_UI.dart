import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../classes/message_model.dart';

class CustomMessage extends StatefulWidget {
  final MessageModel message;

  const CustomMessage(this.message, {super.key});

  @override
  State<CustomMessage> createState() => _CustomMessageState();
}

class _CustomMessageState extends State<CustomMessage> {
  //-------------------------------------------------------------Icon and Color
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.check;
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

  @override
  Widget build(BuildContext context) {
    // Check if the message is sent by the current user
    final isMe = FirebaseAuth.instance.currentUser!.uid == widget.message.senderId;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7, // Limit bubble width
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueGrey.shade900 : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              widget.message.message,style: TextStyle(color: Colors.white ),
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(width: 4), // Spacing between time and icon

                isMe ?
                Icon(
                  getStatusIcon(widget.message.status),
                  size: 12,
                  color: getStatusColor(widget.message.status),
                ) : SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

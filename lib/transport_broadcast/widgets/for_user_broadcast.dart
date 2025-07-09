import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lindelany/static/image_caurosel.dart';
import '../../Constants/Constants.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../static/snackbar.dart';
import '../broadcast_vehicle_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomUserBroadCard extends StatefulWidget {
  final BroadcastModel broadcast;

  const CustomUserBroadCard({super.key, required this.broadcast});

  @override
  State<CustomUserBroadCard> createState() => _CustomUserBroadCardState();
}

class _CustomUserBroadCardState extends State<CustomUserBroadCard> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'broadcasts',
  );

  void _update(String docId, bool isCompleted) async {
    try {
      _reference.doc(docId).update({'completed': isCompleted});
      print('Update successful: completed set to $isCompleted');
    } catch (e) {
      print('Failed to update completed field: $e');
    }
  }

  void _deleted(docID) {
    _reference.doc(docID).delete();
  }

  Future<void> deletePost(String postId, List<String> imageUrls) async {
    try {
      // Delete images from Firebase Storage
      for (String url in imageUrls) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      }

      // Delete the post document
      await FirebaseFirestore.instance
          .collection('broadcasts')
          .doc(postId)
          .delete();
    } catch (e) {
      print('Error deleting post or images: $e');
    }
  }

  String formartedTimeOrDate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    return (difference.inHours < 24)
        ? DateFormat('hh:mm a').format(time)
        : DateFormat('dd MMM yyyy').format(time);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final createdAt = formartedTimeOrDate(widget.broadcast.createdAt.toDate());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //--------------------------------------------------Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customCard1(
              colorr: grey100,
              isPadding: EdgeInsets.zero,

              widgett: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.broadcast.images.isNotEmpty
                      ? SharedWidgets.buildImageCarousel(
                          widget.broadcast.images,
                          screenHeight,
                          screenWidth,
                        )
                      : const SizedBox(),

                  SizedBox(height: hightTen),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.broadcast.uni,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Broadcast text
            Text(
              widget.broadcast.broadcast,

            ),

            SizedBox(height: hightTen),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(createdAt),
                IconButton(
                  onPressed: () {
                    _showMenu(context);
                  },
                  icon: Icon(Icons.edit_rounded, color: blue900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //___________________________________________________________________Show modal

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  widget.broadcast.completed
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.blue,
                ),
                title: Text(widget.broadcast.completed ? 'Show' : 'Hide'),
                onTap: () {
                  final newState = !widget.broadcast.completed;
                  _update(widget.broadcast.postId, newState);

                  Navigator.pop(context);

                  //Local state
                  setState(() {
                    widget.broadcast.completed = newState;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                onTap: () async {
                  CustomDialog.showLoading(context, 'Deleting');
                  Navigator.pop(context);
                  await deletePost(
                    widget.broadcast.postId,
                    widget.broadcast.images,
                  );

                  Navigator.pop(context);

                },
              ),
            ],
          ),
        );
      },
    );
  }
}

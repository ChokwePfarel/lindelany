import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage extends ChangeNotifier{



  Future<List<String>> pickAndUploadImages(BuildContext context, String userId, String postId) async {
    final picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return [];

    if (pickedFiles.length > 4) {
      pickedFiles = pickedFiles.sublist(0, 4);
    }

    List<String> imageUrls = [];
    try {
      for (XFile pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        final ref = FirebaseStorage.instance
            .ref()
            .child('posts/$postId/$fileName');

        final taskSnapshot = await ref.putFile(file);
        final url = await taskSnapshot.ref.getDownloadURL();

        imageUrls.add(url);
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading images')),
      );
    }

    return imageUrls;
  }


}


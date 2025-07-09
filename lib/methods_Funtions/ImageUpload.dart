import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:path/path.dart' as path;


import '../classes/listing_model.dart';
import '../classes/user_model.dart';

class ImageUploadMethod extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference _listingsCollection = FirebaseFirestore.instance.collection('Accommodation');

  // Reusable helper method to pick and crop image to 1:1
  Future<File?> _pickAndCropImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    return cropped != null ? File(cropped.path) : null;
  }

  Future<void> updateProfilePicture(BuildContext context, UserModel user) async {
    final imageFile = await _pickAndCropImage();
    if (imageFile == null) {
      CustomSnackbar.show(context, 'No image selected');
      return;
    }

    final fileName = '${user.userId}_profile_pic.jpg';
    try {
      CustomDialog.showLoading(context, 'Updating..');

      final uploadTask = FirebaseStorage.instance.ref('profile_pictures/$fileName').putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _usersCollection.doc(user.userId).update({
        'profilePictureUrl': downloadUrl,
      });

      user.profilePictureUrl = downloadUrl;

      Navigator.pop(context);
      CustomSnackbar.show(context, 'Profile picture updated successfully!');
    } catch (e) {
      Navigator.pop(context);
      CustomSnackbar.show(context, 'Failed to upload profile picture');
    }
  }

  Future<void> updateAccomPicture(BuildContext context, Listing_model house) async {
    final imageFile = await _pickAndCropImage();
    if (imageFile == null) {
      CustomSnackbar.show(context, 'No image selected');
      return;
    }

    final fileName = '${house.accommodationId}_profile_pic.jpg';
    try {
      CustomDialog.showLoading(context, 'Updating..');

      final uploadTask = FirebaseStorage.instance.ref('profile_pictures/$fileName').putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _listingsCollection.doc(house.accommodationId).update({
        'pictureUrl': downloadUrl,
      });

      house.pictureUrl = downloadUrl;

      Navigator.pop(context);
      CustomSnackbar.show(context, 'Profile picture updated successfully!');
    } catch (e) {
      Navigator.pop(context);
      CustomSnackbar.show(context, 'Failed to upload profile picture');
    }
  }

  ///--------------------

  Future<void> uploadImages(BuildContext context, Listing_model house) async {
    List<XFile> pickedFiles = [];

    try {
      pickedFiles = await ImagePicker().pickMultiImage();
    } catch (e) {
      CustomSnackbar.show(context, 'Failed to pick images: $e');
      return;
    }

    if (pickedFiles.isNotEmpty) {
      CustomDialog.showLoading(context, 'Uploading...');

      final docRef = FirebaseFirestore.instance
          .collection('listings')
          .doc(house.accommodationId)
          .collection('images');

      for (var pickedFile in pickedFiles) {
        try {
          final imageFile = File(pickedFile.path);
          final fileName =
              '${house.accommodationName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final dir = await getTemporaryDirectory();
          final targetPath = '${dir.path}/$fileName';

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            imageFile.path,
            targetPath,
            quality: 85,
            format: CompressFormat.jpeg,
          );

          if (compressedFile == null) throw Exception("Compression failed");

          final ref = FirebaseStorage.instance.ref().child('listings/$fileName');
          await ref.putFile(File(pickedFile.path));
          final downloadUrl = await ref.getDownloadURL();

          await docRef.add({
            'imageUrl': downloadUrl,
            'path': ref.fullPath,
            'uploadedAt': Timestamp.now(),
          });
        } catch (e) {
          Navigator.pop(context);
          print('Compression/upload error: ${e.runtimeType} - $e');
          CustomSnackbar.show(context, 'Failed to upload some images');
          return;
        }
      }

      Navigator.pop(context);
      CustomSnackbar.show(context, 'Images uploaded successfully!');
    }
  }

}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindelany/Constants/constants.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../classes/listing_model.dart';
import '../classes/user_model.dart';

class ImageUploadMethod extends ChangeNotifier {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('Users');
  final CollectionReference _listingsCollection = FirebaseFirestore.instance
      .collection('Accommodation');

  Future<bool> requestPhotoPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+
          final status = await Permission.photos.request();
          //          print('Photos permission status (Android 13+): $status');

          if (status.isGranted) return true;
          if (status.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return false;
        } else {
          // Android 12 and below
          final status = await Permission.storage.request();
          //          print('Storage permission status (Android 12-): $status');

          if (status.isGranted) return true;
          if (status.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return false;
        }
      } else {
        // iOS
        final status = await Permission.photos.request();
        //        print('Photos permission status (iOS): $status');
        return status.isGranted;
      }
    } catch (e) {
      //      print('Error requesting permission: $e');
      return false;
    }
  }

  // Reusable helper method to pick and crop image to 1:1
  Future<File?> _pickAndCropImage() async {
    try {
      //      print('Starting image pick process...');

      final hasPermission = await requestPhotoPermission();
      //      print('Has permission: $hasPermission');

      if (!hasPermission) {
        //        print('Permission denied or not granted');
        return null;
      }

      //      print('Attempting to pick image...');
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: blue900,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
        ],
      );

      if (cropped == null) {
        //        print('Image cropping cancelled');
        return null;
      }

      //      print('Image cropped successfully: ${cropped.path}');
      return File(cropped.path);
    } catch (e) {
      //      print('Error in _pickAndCropImage: $e');
      return null;
    }
  }

  //------------------------------------------------------------------------------

  Future<void> updateProfilePicture(
    BuildContext context,
    UserModel user,
  ) async {
    final imageFile = await _pickAndCropImage();
    if (imageFile == null) {
      CustomSnackbar.show(context, 'No image selected');
      return;
    }

    final fileName = '${user.userId}_profile_pic.jpg';
    try {
      CustomDialog.showLoading(context, 'Updating..');

      final uploadTask = FirebaseStorage.instance
          .ref('profile_pictures/$fileName')
          .putFile(imageFile);
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

  //----------------------------------------------------------------------------

  Future<void> updateAccomPicture(
    BuildContext context,
    Listing_model house,
  ) async {
    final imageFile = await _pickAndCropImage();
    if (imageFile == null) {
      CustomSnackbar.show(context, 'No image selected');
      return;
    }

    final fileName = '${house.accommodationId}_profile_pic.jpg';
    try {
      CustomDialog.showLoading(context, 'Updating..');

      final uploadTask = FirebaseStorage.instance
          .ref('profile_pictures/$fileName')
          .putFile(imageFile);
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

  Future<void> uploadImages(BuildContext context, Listing_model house) async {
    final hasPermission = await requestPhotoPermission();

    if (!hasPermission) {
      return;
    }

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

      final List<String> newUrl = [];

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

          final ref = FirebaseStorage.instance.ref().child(
            'listings/$fileName',
          );
          await ref.putFile(File(pickedFile.path));
          final downloadUrl = await ref.getDownloadURL();

          await docRef.add({
            'imageUrl': downloadUrl,
            'path': ref.fullPath,
            'uploadedAt': Timestamp.now(),
          });

          newUrl.add(downloadUrl);
        } catch (e) {
          Navigator.pop(context);
          ////           print('Compression/upload error: ${e.runtimeType} - $e');
          CustomSnackbar.show(context, 'Failed to upload some images');
          return;
        }
      }

      final imageBox = await Hive.openBox('listingImages');
      final cached = imageBox.get(house.accommodationId)?.cast<String>() ?? [];
      //will store cached on accom id key

      cached.addAll(newUrl);

      await imageBox.put(house.accommodationId, cached);

      Navigator.pop(context);
      CustomSnackbar.show(context, 'Images uploaded successfully!');
    }
  }

  //---------------------------------------------------------Pick a single image

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromGallery({int quality = 70}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (picked == null) return null;
      return File(picked.path);
    } catch (_) {
      return null;
    }
  }
}

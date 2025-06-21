import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../classes/listing_model.dart';
import '../classes/user_model.dart';

class ImageUploadMethod extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('Users');
  final CollectionReference _listingsCollection = FirebaseFirestore.instance
      .collection('Accommodation');

  Future<void> updateProfilePicture(BuildContext context,
      UserModel user) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String fileName = '${user.userId}_profile_pic.jpg';

      try {
        // Show loading dialog before upload starts
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Uploading Profile Picture..."),
                  ],
                ),
              ),
        );

        // Upload to Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_pictures/$fileName')
            .putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await _usersCollection.doc(user.userId).update(
            {'profilePictureUrl': downloadUrl});

        // Update the user instance
        user.profilePictureUrl = downloadUrl;

        // Close loading dialog after upload completes
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture updated successfully!'),
        ));
      } catch (e) {
        print('Error uploading profile picture: $e');

        // Close loading dialog before showing error
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to upload profile picture'),
        ));
      }
    }
  }

  Future<void> updateAccomPicture(BuildContext context,
      Listing_model house) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload to Firebase Storage
      String fileName = '${house.accommodationId}_profile_pic.jpg';
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Uploading..."),
                  ],
                ),
              ),
        );
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_pictures/$fileName')
            .putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await _listingsCollection.doc(house.accommodationId)
            .update({'pictureUrl': downloadUrl});

        // Update the user instance
        house.pictureUrl = downloadUrl;

        // Close loading dialog after upload completes
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture updated successfully!'),
        ));
      } catch (e) {
        print('Error uploading profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to upload profile picture'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No image selected'),
      ));
    }
  }

  ///--------------------
  Future<void> uploadImages(BuildContext context, Listing_model house) async {
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Uploading..."),
            ],
          ),
        ),
      );

      List<Map<String, String>> uploadedImages = [];

      for (var pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);
        String fileName =
            '${house.accommodationName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        try {
          // Upload image
          final ref = FirebaseStorage.instance.ref().child('listings/$fileName');
          await ref.putFile(imageFile);
          final downloadUrl = await ref.getDownloadURL();

          // Add to image list
          uploadedImages.add({
            'url': downloadUrl,
            'path': ref.fullPath, // For future deletion
          });

        } catch (e) {
          Navigator.pop(context); // close dialog if error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          return;
        }
      }

      Navigator.pop(context); // Close loading dialog

      // Update Firestore with the uploaded image info
      final docRef = FirebaseFirestore.instance
          .collection('listings')
          .doc(house.accommodationId); // Assume your model has an ID

      await docRef.update({
        'images': FieldValue.arrayUnion(uploadedImages),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Images uploaded successfully.')),
      );
    }
  }


//Uploading for Accom
  Future<void> uploadImagess(BuildContext context, Listing_model house) async {
    // Allow user to select multiple images.
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);

        // Generate a unique filename for the image.
        String fileName =
            '${house.accommodationName}_${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg';

        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Uploading..."),
                    ],
                  ),
                ),
          );

          // Upload the image to Firebase Storage.
          UploadTask uploadTask = FirebaseStorage.instance
              .ref('user_uploads/${house.accommodationId}/$fileName')
              .putFile(imageFile);

          TaskSnapshot taskSnapshot = await uploadTask;
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();

          // Save the image URL to Firestore under the accommodation's document.
          await _listingsCollection.doc(house.accommodationId).collection(
              'uploads')
              .add({
            'imageUrl': downloadUrl,
            'uploadedAt': Timestamp.now(),
          });

          // Close loading dialog after upload completes
          Navigator.pop(context);
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload one of the images')),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

}
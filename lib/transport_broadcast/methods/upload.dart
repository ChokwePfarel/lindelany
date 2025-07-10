
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class UploadImage extends ChangeNotifier {
  Future<List<String>> pickAndUploadImages(BuildContext context,
      String userId,
      String postId,) async {
    final picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return [];

    if (pickedFiles.length > 4) {
      pickedFiles = pickedFiles.sublist(0, 4);
    }

    List<String> imageUrls = [];

    try {
      for (XFile pickedFile in pickedFiles) {
        // Read file bytes
        final bytes = await pickedFile.readAsBytes();

        // Decode image
        img.Image? originalImage = img.decodeImage(bytes);
        if (originalImage == null) continue;

        // Crop to square
        int width = originalImage.width;
        int height = originalImage.height;
        int cropSize = width < height ? width : height;

        int xOffset = (width - cropSize) ~/ 2;
        int yOffset = (height - cropSize) ~/ 2;

        img.Image cropped = img.copyCrop(
          originalImage,
          x: xOffset,
          y: yOffset,
          width: cropSize,
          height: cropSize,
        );


        // Encode back to jpg
        List<int> jpg = img.encodeJpg(cropped, quality: 90);
        Uint8List croppedBytes = Uint8List.fromList(jpg);

        // Upload to Firebase
        final fileName = '${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(
            'posts/$postId/$fileName');

        final taskSnapshot = await ref.putData(croppedBytes);
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

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUploadService {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'products',
  );

  /// Uploads images to Firebase Storage under a given folder and doc ID.
  /// Example: folder='broadcasts', docId='1234' → path: broadcasts/1234/image.jpg
  ///
  static Future<List<String>> uploadImages({
    required List<XFile> pickedFiles,
    required String folder,
    required String docId,
    int maxSide = 1080,
    int quality = 85,
  }) async {

    final List<String> imageUrls = [];

    for (final XFile xf in pickedFiles) {
      try {
        final originalFile = File(xf.path);

        // Crop and compress before upload
        final croppedFile = await cropToSquareJpeg(
          originalFile,
          maxSide: maxSide,
          quality: quality,
        );

        // Unique filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Storage path e.g. products/abc123/1696872140.jpg
        final ref = FirebaseStorage.instance.ref().child(
          '$folder/$docId/$fileName',
        );

        // Upload
        final task = await ref.putFile(croppedFile);

        // Get URL
        final url = await task.ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
//        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  /// Deletes all images stored under a given folder and doc ID.---------------
  /// Example: folder='broadcasts', docId='1234' → deletes everything under broadcasts/1234/

  Future<void> deleteImages({
    required String folder,
    required String docId,
  }) async {
    try {
      await _reference.doc(docId).delete();

      final ref = FirebaseStorage.instance.ref('$folder/$docId');
      final listResult = await ref.listAll();

      if (listResult.items.isNotEmpty) {
        for (final item in listResult.items) {
          await item.delete();
        }
      }

//      print('Deleted all images in $folder/$docId');
    } catch (e) {
//      print('Error deleting images in $folder/$docId: $e');
    }
  }
}

Future<File> cropToSquareJpeg(
    File original, {
      int? maxSide,
      int quality = 85,
    }) async {
  final bytes = await original.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Unsupported or corrupt image: ${original.path}');
  }

  final side = math.min(decoded.width, decoded.height);
  final x = ((decoded.width - side) / 2).round();
  final y = ((decoded.height - side) / 2).round();

  img.Image square = img.copyCrop(decoded, x: x, y: y, width: side, height: side);

  if (maxSide != null && side > maxSide) {
    square = img.copyResize(square, width: maxSide, height: maxSide); // stays square
  }

  final jpgBytes = img.encodeJpg(square, quality: quality);

  final tmpDir = await getTemporaryDirectory();
  final outPath = p.join(
    tmpDir.path,
    'sq_${DateTime.now().millisecondsSinceEpoch}_${p.basename(original.path)}.jpg',
  );
  final outFile = File(outPath);
  await outFile.writeAsBytes(jpgBytes, flush: true);
  return outFile;
}

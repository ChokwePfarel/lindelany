import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';


class GetImages{
  Future<List<String>> getListingImages(String accommodationId) async {
    final imageBox = await Hive.openBox('listingImages');
    final cachedImages = imageBox.get(accommodationId)?.cast<String>();

    if (cachedImages != null && cachedImages.isNotEmpty) {
      return cachedImages;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .doc(accommodationId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .get();

    final urls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    // Cache result
    await imageBox.put(accommodationId, urls);

    return urls;
  }
}

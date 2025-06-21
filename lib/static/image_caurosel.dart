import 'package:flutter/cupertino.dart';

class SharedWidgets {
  static Widget buildImageCarousel(List<String> images, double width, double height) {
    final imageCount = images.length.clamp(1, 4);

    return AspectRatio(
      aspectRatio: imageCount > 2 ? 2 : imageCount.toDouble(),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageCount > 2 ? 2 : imageCount,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: imageCount,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}

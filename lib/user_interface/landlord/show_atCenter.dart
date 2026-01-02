import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ShowAtCenter extends StatelessWidget {
  final String imagesUrl;
  const ShowAtCenter({super.key, required this.imagesUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imagesUrl,
          fit: BoxFit.contain,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Center(
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
              ),
          errorWidget: (context, url, error) =>
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

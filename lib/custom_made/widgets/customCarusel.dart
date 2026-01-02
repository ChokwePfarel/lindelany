import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StreamCarousel extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final double height;
  final String imageFieldName;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final CarouselOptions? carouselOptions;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit imageFit;

  const StreamCarousel({
    super.key,
    required this.stream,
    required this.height,
    this.imageFieldName = 'imageUrl',
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.carouselOptions,
    this.borderRadius,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
        }

        // Handle error state
        if (snapshot.hasError) {
          return errorWidget ??
              Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.error)),
              );
        }

        // Handle data state
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final imagesUrls = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data[imageFieldName] as String;
          }).toList();

          return CarouselSlider(
            options:
                carouselOptions ??
                CarouselOptions(
                  height: height,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1200),
                  autoPlayCurve: Curves.easeInOut,
                  pauseAutoPlayOnTouch: true,
                ),
            items: imagesUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: borderRadius ?? BorderRadius.circular(16.0),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: imageFit,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        }

        // Handle empty state
        return emptyWidget ??
            Container(
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(CupertinoIcons.camera_fill, size: 40),
              ),
            );
      },
    );
  }
}

class ProductImagesCarousel extends StatelessWidget {
  final String productId;
  final double height;

  const ProductImagesCarousel({
    super.key,
    required this.productId,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Stream for a specific product document
    Stream<DocumentSnapshot> productStream = FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: productStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final productData = snapshot.data!.data() as Map<String, dynamic>;
        final List<String> images = List<String>.from(
          productData['images'] ?? [],
        );

        if (images.isEmpty) {
          return _buildEmptyState();
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: height,
            autoPlay: images.length > 1,
            viewportFraction: 1.0,
            autoPlayInterval: Duration(seconds: 3),
          ),
          items: images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => _buildLoadingState(),
                    errorWidget: (context, url, error) => _buildErrorState(),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLoadingState() => Container(
    height: height,
    color: Colors.grey[200],
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorState() => Container(
    height: height,
    color: Colors.grey[200],
    child: Center(child: Icon(Icons.error)),
  );

  Widget _buildEmptyState() => Container(
    height: height,
    color: Colors.grey[200],
    child: Center(child: Icon(Icons.image_not_supported)),
  );
}

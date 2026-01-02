import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Market/firebaseService/productModel.dart';
import 'package:lindelany/constants/scale.dart';

import '../../Constants/constants.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2, // Added shadow for better visual
            child: Stack(
              children: [
                // Product image
                SizedBox(
                  height: screenHeight * 20,
                  width: screenWidth * 20,
                  child: product.images.isNotEmpty
                      ? (product.images.last.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: product.images.last,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.error),
                              )
                            : Image.asset(
                                product.images.last,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.error),
                              ))
                      : Image.asset(
                          'assets/broken.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                // New-Used badge positioned on top of image
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isNew ? 'NEW' : 'USED',
                      style: theme.bodyMedium!.copyWith(
                        color: product.isNew ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              product.productName,
              style: theme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis, // Prevent long text overflow
              ),
              maxLines: 1, // Limit to one line
            ),

            // Price
            Text(
              'R${product.price.toStringAsFixed(2) ?? '0.00'}',
              // Dynamic price from product model
              style: theme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: blue900, // Price color
              ),
            ),
          ],
        ),
      ],
    );
  }
}

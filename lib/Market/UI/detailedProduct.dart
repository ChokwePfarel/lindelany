import 'package:flutter/material.dart';
import 'package:lindelany/Market/firebaseService/productSet.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/custom_made/widgets/customCarusel.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:lindelany/firebase_Set/user.dart';
import 'package:provider/provider.dart';

import '../../Constants/constants.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/user_model.dart';
import '../firebaseService/productModel.dart';

class DetailedProduct extends StatefulWidget {
  final ProductModel product;
  final UserModel owner;

  const DetailedProduct({
    super.key,
    required this.product,
    required this.owner,
  });

  @override
  State<DetailedProduct> createState() => _DetailedProductState();
}

class _DetailedProductState extends State<DetailedProduct> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final user = Provider.of<UserProvider>(context).user;
    final student = Provider.of<StudentProvider>(context).currentStudentInfo;

    final stream = ProductSet().getSixProducts(
      student!.uni,
      widget.product.category,
      excludeProductId: widget.product.productId,
    );
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----------------------------Image slide show with stack of new or old
            Stack(
              children: [
                ProductImagesCarousel(
                  productId: widget.product.productId,
                  height: 400,
                ),

                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Text(
                    widget.product.isNew ? 'New' : 'Used',
                    style: theme.bodyLarge!.copyWith(
                      color: widget.product.isNew ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  Text(
                    widget.product.description,
                    style: theme.bodySmall!.copyWith(),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  Text(
                    'R${widget.product.price.toStringAsFixed(2)}',
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'This product is being soled by ${widget.product.sellerName}',
                    style: theme.bodyMedium!.copyWith(fontSize: 10),
                  ),

                  SizedBox(height: screenHeight * 0.020),

                  Text(
                    'Related Items',
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  StreamBuilder<List<ProductModel>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: screenHeight * 0.2,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return SizedBox(
                          height: screenHeight * 0.2,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(height: 8),
                                Text('Error loading related items'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(
                          height: screenHeight * 0.2,
                          child: Center(child: Text('No related items found')),
                        );
                      }

                      final relatedProduct = snapshot.data!;

                      return SizedBox(
                        height: screenHeight * 0.19,
                        child: Center(child: Text('No related items found')),
                      );

                      /*SizedBox(
                        height: 200, // Fixed height for horizontal list
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: relatedProduct.length,
                          itemBuilder: (context, index) {
                            final product = relatedProduct[index];
                            return Container(
                              margin: EdgeInsets.only(
                                right: 8, // Space between items
                                left: index == 0 ? 8 : 0, // Left margin only for first item
                              ),
                              width: 160, // Fixed width for each product card
                              child: ProductCard(product: product),
                            );
                          },
                        ),
                      );*/
                    },
                  ),

                  SizedBox(height: screenHeight * 0.050),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<chatProvider>(
                            context,
                            listen: false,
                          ).navigateToChat(context, widget.owner);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: screenHeight * 0.060,
                            width: screenWidth * 0.92,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: blue900,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Start a Chat',
                                  style: theme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      /*SizedBox(width: screenWidth * 0.010,),

                      GestureDetector(
                        onTap: ()=> CustomSnackbar.show(context,'Feature Coming soon'),
                        child: Container(
                          height: screenHeight * 0.060,
                          width: screenWidth * 0.13,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: blue900
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(CupertinoIcons.heart_fill,color: Colors.white,),
                          ),
                        ),
                      )*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lindelany/Market/UI/createProduct.dart';
import 'package:lindelany/Market/UI/editProduct.dart';
import 'package:lindelany/Market/customMad/productCard.dart';
import 'package:lindelany/Market/firebaseService/productModel.dart';
import 'package:lindelany/Market/firebaseService/productSet.dart';
import 'package:lindelany/custom_made/for_press/customElevated.dart';
import 'package:lindelany/user_interface/Common/accommodations.dart';

import '../../Constants/constants.dart';

class MyProducts extends StatelessWidget {
  const MyProducts({super.key});

  @override
  Widget build(BuildContext context) {

    final stream = ProductSet().getCurrentUserProducts();
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blue900,
        title: Text('My Products',style:
          Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),

        actions: [
          IconButton(onPressed: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=> Accomodations()));
          }, icon: Icon(Icons.home,color: Colors.white,size: 25,))
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<ProductModel>>(
            stream: stream,
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: blue900),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'An error occurred while loading products.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final products = snapshot.data;
              if (products == null || (products.isEmpty)) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'You do not have products yet.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: blue900
                        ),
                      ),
                    ),

                    const SizedBox(height: 10,),

                    customElevated(nextPage: CreateProduct(), LabelText: 'Sell')
                  ],
                );
              }

              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0.2,
                      mainAxisSpacing: 0.8,
                      childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index){

                    final product = products[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> EditProduct(product: product)));
                      },
                        child: ProductCard(product: product));
                  });
            }),
      ),

    );
  }
}

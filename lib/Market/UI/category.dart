import 'package:flutter/material.dart';
import 'package:lindelany/Market/UI/allProducts.dart';
import 'package:lindelany/Market/customMad/categoryCard.dart';

import '../customMad/lists.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    //access list, convert to a list of key value pairs so it can be indexed
    final categoryList = categoryDetails.entries.toList();

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final entry = categoryList[index];
                final title = entry.value['title'];
                final description = entry.value['description'];
                final imageUrl = entry.value['imageUrl'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProducts(category: title!),
                      ),
                    );
                  },
                  child: CategoryCard(
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

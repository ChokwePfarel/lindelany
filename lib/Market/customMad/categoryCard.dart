import 'package:flutter/material.dart';
import 'package:lindelany/constants/scale.dart';

import '../../Constants/Constants.dart';

class CategoryCard extends StatelessWidget {
  final String? title;
  final String? description;
  final String? imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Card(
      color: Colors.grey,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.asset(imageUrl!, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: theme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: blue900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.010),

                Text(
                  description!,
                  style: theme.bodyMedium!.copyWith(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

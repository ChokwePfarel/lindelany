import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String bodyText;
  final VoidCallback onClose;

  const InfoCard({
    super.key,
    required this.title,
    required this.bodyText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.040),
            Text(
              bodyText,
              style: theme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onClose,
              splashRadius: 10,
            ),
          ),
        ),
      ],
    );
  }
}

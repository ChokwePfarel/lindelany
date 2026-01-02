import 'package:flutter/material.dart';

import '../custom_made/widgets/colums.dart';

class ExpandableTextCard extends StatefulWidget {
  final String title;
  final String text;
  final int trimLength;
  final ScrollController controller;

  const ExpandableTextCard({
    super.key,
    required this.title,
    required this.text,
    required this.trimLength,
    required this.controller,
  });

  @override
  State<ExpandableTextCard> createState() => _ExpandableTextCardState();
}

class _ExpandableTextCardState extends State<ExpandableTextCard> {
  bool isExpanded = false;
  final GlobalKey _textKey = GlobalKey();

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textKey.currentContext != null) {
        Scrollable.ensureVisible(
          _textKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayText = widget.text;
    if (!isExpanded && widget.text.length > widget.trimLength) {
      displayText = '${widget.text.substring(0, widget.trimLength)}...';
    }

    return customCard1(
      widgett: Column(
        key: _textKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleExpanded,
            child: Text(
              displayText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

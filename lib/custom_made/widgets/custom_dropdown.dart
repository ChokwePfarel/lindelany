import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final List<T> items;
  final T value;
  final void Function(T?) onChanged;
  final String Function(T)? displayItem;
  final Color borderColor;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.items,
    required this.value,
    required this.onChanged,
    this.displayItem,
    this.borderColor = const Color(0xFF002D72), // blue900
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: DropdownButtonFormField<T>(
            isExpanded: true,
            value: value,
              decoration: InputDecoration(
                labelText: labelText,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  displayItem != null ? displayItem!(item) : item.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final Function(T?)? onChanged;
  final String Function(T)? displayItem;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double focusedBorderWidth;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelText,
    required this.onChanged,
    this.displayItem,
    this.padding,
    this.borderRadius = 20,
    this.focusedBorderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade900),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue.shade900,
              width: focusedBorderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade900),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayItem != null ? displayItem!(item) : item.toString(),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
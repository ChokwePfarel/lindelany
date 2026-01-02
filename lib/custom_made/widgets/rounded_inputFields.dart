import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String validationNote;
  final String initialValue;
  final void Function(String) onChanged;

  const InputField({
    super.key,
    required this.label,
    required this.validationNote,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: label.toLowerCase().contains('price')
          ? TextInputType.number
          : TextInputType.multiline,
      maxLines: 2,
      /*minLines: label.toLowerCase().contains('about product') ? 3 : 1,
      maxLines: label.toLowerCase().contains('description') ? null : 1,*/
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onChanged: (value) => onChanged(value.trim().toUpperCase()),
      validator: (value) {
        if (value == null || value.isEmpty) return validationNote;
        return null;
      },
    );
  }
}

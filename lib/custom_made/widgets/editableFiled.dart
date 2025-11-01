import 'package:flutter/material.dart';

import '../../Constants/Constants.dart';


class buildEdditable extends StatefulWidget {
  final String title;
  final String value;
  final Function(String) onSave;
  final String hintText;
  final String? Function(String?) validator;

  const buildEdditable({super.key, required this.title, required this.value, required this.onSave, required this.hintText,required this.validator});

  @override
  State<buildEdditable> createState() => _buildEdditableState();
}

class _buildEdditableState extends State<buildEdditable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          subtitle: Text(widget.value.isEmpty ? 'Not set' : widget.value),
          trailing: Icon(widget.value.isEmpty ? Icons.arrow_forward_ios_rounded : Icons.edit, color: blue900),
          onTap: () {
            debugPrint('Tapped ${widget.title}');
            _showEditDialog(
              fieldName: widget.title,
              initialValue: widget.value,
              onSave: (newValue) => setState(() => widget.onSave(newValue)),
              hintText: widget.hintText,
              validator: widget.validator,
            );
          }


        ),
        const Divider(),
      ],
    );
  }

  Future<void> _showEditDialog({
    required String fieldName,
    required String initialValue,
    required Function(String) onSave,
    required String hintText,
    required String? Function(String?) validator,
  }) async {
    final TextEditingController controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    debugPrint('showing dialog for $fieldName');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit $fieldName',style:Theme.of(context).textTheme.bodyMedium),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: hintText),
              validator: validator,
              maxLines: 2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onSave(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}





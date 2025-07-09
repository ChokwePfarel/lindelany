import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Custominput extends StatelessWidget {
  final TextEditingController Controller;
  final String HintText;
  final double circular;
  final bool isPadding;
  final bool enabled;
  final int lineNumb;
  final Function(String)? onChange;

  const Custominput({
    super.key,
    required this.Controller,
    required this.HintText,
    required this.circular,
    required this.isPadding,
    required this.enabled,
    required this.lineNumb,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: Controller,
      maxLines: lineNumb,
      onChanged: enabled ? onChange : null,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        contentPadding: isPadding
            ? EdgeInsets.symmetric(vertical: 10, horizontal: 20)
            : EdgeInsets.zero,
        hintText: HintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(40),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          borderRadius: BorderRadius.circular(circular),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(circular),
        ),
      ),
    );
  }
}

class CustomFormInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool isObscured;
  final VoidCallback? onSuffixIconPressed;
  final bool isPassword;

  const CustomFormInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.isObscured = false,
    this.onSuffixIconPressed,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(20),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onSuffixIconPressed,
                icon: Icon(
                  isObscured
                      ? CupertinoIcons.eye_fill
                      : CupertinoIcons.eye_slash_fill,
                ),
              )
            : null,
      ),
      validator: validator,
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final IconButton? suffixIcon;  // Made nullable with ?

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.controller,
    this.suffixIcon,  // Now optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: AppTheme.inputTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.inputTextStyle.copyWith(color: Colors.white38),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white54,
          ),
          suffixIcon: suffixIcon,  // Will be null if not provided
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({super.key,required this.controller,required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: 
      InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color:Color(0xFF0099CD)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color:Color(0xFF0099CD)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        
      ),
      
    );
  }
}
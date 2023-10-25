import 'package:flutter/material.dart';

class MyTextFormFeild extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const MyTextFormFeild({Key? key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 183, 183, 183)), // Bottom border color
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 183, 183, 183)), // Bottom border color when focused
        ),
        isDense: true, // Reduces the height of the input field
        contentPadding: EdgeInsets.only(top: 20), // Padding for the top text
      ),
    );
  }
}

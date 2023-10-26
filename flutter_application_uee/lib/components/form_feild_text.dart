import 'package:flutter/material.dart';

class MyTextFormFeild extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const MyTextFormFeild({Key? key, required this.controller, required this.hintText}) : super(key: key);

  @override
  _MyTextFormFeildState createState() => _MyTextFormFeildState();
}

class _MyTextFormFeildState extends State<MyTextFormFeild> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.only(top: isFocused ? 20 : 0), 
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.hintText,
          labelStyle: TextStyle(
            color: isFocused ? Colors.grey : Colors.grey[500],
          ),
          hintText: '',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 183, 183, 183)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 183, 183, 183)),
          ),
          isDense: true,
          contentPadding: EdgeInsets.only(top: 20),
        ),
        onChanged: (text) {
          setState(() {
            isFocused = text.isNotEmpty;
          });
        },
        onTap: () {
          setState(() {
            isFocused = true;
          });
        },
        onEditingComplete: () {
          setState(() {
            isFocused = false;
          });
        },
        onSubmitted: (_) {
          setState(() {
            isFocused = false;
          });
        },
        focusNode: FocusNode(),
      ),
    );
  }
}


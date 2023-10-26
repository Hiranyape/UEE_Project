import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/foster_login_page.dart';
import 'package:flutter_application_uee/pages/foster_register_page.dart';
import 'package:flutter_application_uee/pages/user_login_page.dart';
import 'package:flutter_application_uee/pages/user_register_page.dart';

class LoginOrRegisterFoster extends StatefulWidget {
  const LoginOrRegisterFoster({super.key});

  @override
  State<LoginOrRegisterFoster> createState() => _LoginOrRegisterFoster();
}

class _LoginOrRegisterFoster extends State<LoginOrRegisterFoster> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return FosterLoginPage(onTap: togglePages);
    } else {
      return FosterRegisterPage(
        onTap: togglePages,
        fosterEmail: '',
      );
    }
  }
}

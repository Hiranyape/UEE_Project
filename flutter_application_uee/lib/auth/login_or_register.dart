import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/user_login_page.dart';
import 'package:flutter_application_uee/pages/user_register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegister();

}

class _LoginOrRegister extends State<LoginOrRegister>{

  bool showLoginPage = true;

  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override 
  Widget build(BuildContext context){
    if(showLoginPage){
      return UserLoginPage(onTap :togglePages);
    }else{
      return UserRegisterPage(onTap:togglePages);
    }
  }
}
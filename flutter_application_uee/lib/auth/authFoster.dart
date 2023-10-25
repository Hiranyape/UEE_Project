import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/auth/login_or_register.dart';
import 'package:flutter_application_uee/auth/login_or_register_foster.dart';
import 'package:flutter_application_uee/pages/foster_home_page.dart';
import 'package:flutter_application_uee/pages/user_home_page.dart';

class AuthFoster extends StatelessWidget {
  const AuthFoster({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          //user is logged in
          if(snapshot.hasData){
            return const FosterHomePage();
          }
          //user is not logged in 
          else{
            return const LoginOrRegisterFoster();
          }
        },)
    );
  }
}
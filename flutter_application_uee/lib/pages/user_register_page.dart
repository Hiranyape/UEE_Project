import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/components/text_feild.dart';

class UserRegisterPage extends StatefulWidget{
  final Function()? onTap;
  const UserRegisterPage({super.key,required this.onTap });

  @override
  State<UserRegisterPage> createState() =>_UserRegisterPageState();

}

class _UserRegisterPageState extends State<UserRegisterPage>{
  final usernameController = TextEditingController();
  final contactController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign user up 

  void signUp() async{
    //show loading circle 
    showDialog(context: context, builder: (context)=>const Center(
      child:CircularProgressIndicator()
    ));

    //make sure password march
    if(passwordController.text!=confirmPasswordController.text){
      Navigator.pop(context);
      displayMessage("Passowrds don't match!");
      return;
    }

    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailTextController.text, password: 
      passwordController.text);
    }on FirebaseAuthException catch(e){
      //pop loading circle 
      Navigator.pop(context);
      //display error message
     displayMessage(e.code);
    }

  }

  //display a dialog message
  void displayMessage(String message){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(message),
    ));
  }

   @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:Center(
          child:Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
        const SizedBox(height: 10),
        const Image(image: AssetImage('assets/images/logo.png')),

         const SizedBox(height: 10),

        const Align(
        alignment: Alignment.centerLeft, // Align only this text to the left
        child: Text(
          "Create New\nAccount",
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        ),
        const Text(
          "Creating paw-sitive experiences, one sign-up at a time!",
          style: TextStyle(fontSize: 16,color: Colors.grey),
        ),

        const SizedBox(height: 10),
        const SizedBox(height: 10),
        // MyTextField(
        //   controller: usernameController,
        //   hintText: 'Username',
        //   obscureText: false,
        // ),
        // const SizedBox(height: 10),
        // MyTextField(
        //   controller: contactController,
        //   hintText: 'Contact',
        //   obscureText: false,
        // ),
        // const SizedBox(height: 10),
        MyTextField(
          controller: emailTextController,
          hintText: 'Email',
          obscureText: false,
        ),
        
        const SizedBox(height: 10),

         MyTextField(
          controller: passwordController,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 10),

         MyTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: true,
        ),

        const SizedBox(height: 100),


        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?"),
            const SizedBox(width:4),
            GestureDetector(
              onTap: widget.onTap,
              child: const Text(
              "Sign In",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            ),
            
          ],
        ),

        const SizedBox(height: 25),

         MyButton(onTap: signUp, text: 'Sign Up')




      ],)
    ))));
      
  }
}
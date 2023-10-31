import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/components/text_feild.dart';

class FosterLoginPage extends StatefulWidget {
  final Function()? onTap;
  const FosterLoginPage({super.key, required this.onTap});

  @override
  State<FosterLoginPage> createState() => _FosterLoginPageState();
}

class _FosterLoginPageState extends State<FosterLoginPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    //show loading circle
    showDialog(
        context: (context),
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordController.text,
      );

      final userEmail = userCredential.user?.email;

      final userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userEmail)
          .get();
      final userRole = userSnapshot["role"];
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            const Image(
                                image: AssetImage('assets/images/logo.png')),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment
                                  .centerLeft, // Align only this text to the left
                              child: Text(
                                "Hello,\nWelcome Back",
                                style: TextStyle(
                                    fontSize: 50, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Your pet's happiness begins with a click. Log in below",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 80),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: widget.onTap,
                                  child: const Text(
                                    "Register now",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            MyButton(onTap: signIn, text: 'Sign In'),
                          ],
                        ))))));
  }
}

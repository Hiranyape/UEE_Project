import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_services_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void navigateToPetServicePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        // builder: (context) => const AuthPage(),
        builder: (context) => const PetServicesPage(),
      ),
    );
  }

  // sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Wall"),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: MyButton(
          onTap: navigateToPetServicePage,
          text: "Pet Service",
        ),
      )),
    );
  }
}

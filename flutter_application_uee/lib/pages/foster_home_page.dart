import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/add_foster_journey.dart';
import 'package:flutter_application_uee/pages/foster_profilepage.dart';
import 'package:flutter_application_uee/pages/my_fosters_page.dart';
import 'package:flutter_application_uee/pages/register_as_foster.dart';
import 'package:flutter_application_uee/pages/register_my_pet.dart';

class FosterHomePage extends StatefulWidget {
  const FosterHomePage({super.key});

  @override
  State<FosterHomePage> createState() => _FosterHomePageState();
}

class _FosterHomePageState extends State<FosterHomePage> {
  String userEmail = "";
  // Sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void navigateToMyFosterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MyFosterPage()), // Instantiate your AddFosterJorney widget here.
    );
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();
    // Access the user's email in initState
    final currentUser = FirebaseAuth.instance.currentUser;
    userEmail =
        currentUser?.email ?? ""; // Get the email if the user is signed in.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const MyFosterPage();
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFECEFFD),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        width: 380,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            OverflowBox(
                              maxHeight: double.infinity,
                              minHeight: 0,
                              alignment: Alignment(0, 0.6),
                              child: Image.asset('assets/images/dog3.png',
                                  width: 370, height: 170, fit: BoxFit.cover),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: const Text(
                                "My Fosters",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Text(
                        "Fosters",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 230),
                      Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Reminders",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFEDF6FB),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    width: 380,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        OverflowBox(
                          maxHeight: double.infinity,
                          minHeight: 0,
                          alignment: Alignment(-1.0, 1.0),
                          child: Image.asset('assets/images/cat1.png',
                              width: 150, height: 150, fit: BoxFit.cover),
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: Text(
                            "Check your\nreminders ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Arrow icon at the bottom-right corner
                        const Positioned(
                          bottom: 10,
                          right: 10,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pet Food Stores",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFEDF6FB),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    width: 380,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        OverflowBox(
                          maxHeight: double.infinity,
                          minHeight: 0,
                          alignment: const Alignment(-1.0, 0.8),
                          child: Image.asset('assets/images/food1.png',
                              width: 150, height: 150, fit: BoxFit.cover),
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: Text(
                            "Find pet food \nstores ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Arrow icon at the bottom-right corner
                        const Positioned(
                          bottom: 10,
                          right: 10,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GestureDetector for adding foster details
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FosterProfilePage(fosterEmail: userEmail),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      width: 380,
                      height: 50,
                      child: Center(
                        child: Text(
                          "View My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

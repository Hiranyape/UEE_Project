import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/my_pets.dart';
import 'package:flutter_application_uee/pages/user_profile.dart';
import 'package:flutter_application_uee/pages/user_side_FosterDetailsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<List<QueryDocumentSnapshot>> getFosterUsers() async {
    try {
      QuerySnapshot fosterSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Foster')
          .get();

      return fosterSnapshot.docs;
    } catch (e) {
      print("Error fetching foster users: $e");
      return [];
    }
  }

  void navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserProfile(userEmail: currentUser?.email ?? ""),
      ),
    );
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
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: navigateToUserProfile, // Navigate to user profile when tapped
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(currentUser?.photoURL ?? ""),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentUser?.displayName ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(currentUser?.email ?? "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                    const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF0099CD),
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
                          alignment: Alignment(-1.0, 1.0),
                          child: Image.asset('assets/images/dog1.png',
                              width: 150, height: 170, fit: BoxFit.cover),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            "Find the \nPerfect foster today! ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fosters",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<QueryDocumentSnapshot>>(
                      future: getFosterUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          final List<QueryDocumentSnapshot>? fosterUsers =
                              snapshot.data;

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: fosterUsers?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot user = fosterUsers![index];
                              String name = user['email'];

                              return InkWell(
                                  onTap: () {
                                    String email = user[
                                        'email']; // Get the email from the DocumentSnapshot
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FosterDetailsPage(
                                          email: email,
                                          currentUser: currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.all(10),
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0099CD),
                                            ),
                                          ),
                                          Text(
                                            name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Journey Tracker",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MyPetsPage();
                      }));
                    },
                    child: Container(
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
                      height: 150,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          OverflowBox(
                            maxHeight: double.infinity,
                            minHeight: 0,
                            alignment: Alignment(-1.0, 1.0),
                            child: Image.asset('assets/images/dog2.png',
                                width: 150, height: 170, fit: BoxFit.cover),
                          ),
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: Text(
                              "Check how your dog \nis doing today with \nthe foster ",
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

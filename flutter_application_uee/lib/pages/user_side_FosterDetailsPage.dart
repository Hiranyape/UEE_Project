import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_uee/pages/rating_page.dart';

class FosterDetailsPage extends StatefulWidget {
  final String email;
  final User? currentUser;

  FosterDetailsPage({required this.email, required this.currentUser});

  @override
  _FosterDetailsPageState createState() => _FosterDetailsPageState();
}

class _FosterDetailsPageState extends State<FosterDetailsPage> {
  String name = "";
  String age = "";
  String sex = "";
  String about = "";
  List<String> extraPoints = [];
  String fosterImage = ""; // Store the image URL

  Future<void> fetchFosterDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('fosters')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot fosterDoc = querySnapshot.docs.first;
        setState(() {
          name = fosterDoc['name'];
          age = fosterDoc['age'];
          sex = fosterDoc['sex'];
          about = fosterDoc['about'];
          extraPoints = List<String>.from(fosterDoc['extra_points']);
          fosterImage = fosterDoc['image']; // Assign the image URL
        });
      }
    } catch (e) {
      print("Error fetching foster details: $e");
    }
  }

  void rateFoster() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(email: widget.email),
      ),
    );
  }

  Future<void> sendRequest() async {
    try {
      if (widget.currentUser != null) {
        String currentUserEmail = widget.currentUser!.email ?? '';
        String fosterEmail = widget.email;

        // Store the request in Firestore
        await FirebaseFirestore.instance.collection('fosterRequests').add({
          'currentUserEmail': currentUserEmail,
          'fosterEmail': fosterEmail,
          'status': 'pending',
        });

        // Show a success message
        showSuccessMessage("Request sent successfully");
      }
    } catch (e) {
      // Show an error message
      showErrorMessage("Failed to send request: $e");
    }
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchFosterDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Foster Details"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 80,
              backgroundImage: fosterImage.isNotEmpty
                  ? NetworkImage(
                      fosterImage) // Use the actual URL from Firestore
                  : AssetImage('assets/images/profile_Default.jpg')
                      as ImageProvider<Object>,
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Foster Email: ${widget.email}"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Name: $name"),
          ),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text("Age: $age"),
          ),
          ListTile(
            leading: Icon(Icons.male),
            title: Text("Sex: $sex"),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About: $about"),
          ),
          ListTile(
            leading: Icon(Icons.check),
            title: Text("Extra Points:"),
            subtitle: Column(
              children: extraPoints.map((point) {
                return ListTile(
                  leading: Icon(
                    Icons.pets,
                    color: Colors.green,
                  ),
                  title: Text(point),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: rateFoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text("Rate Foster"),
              ),
              ElevatedButton(
                onPressed: sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text("Request"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

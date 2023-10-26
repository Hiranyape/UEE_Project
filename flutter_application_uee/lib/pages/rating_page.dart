import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'assignedPoints.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RatingPage extends StatefulWidget {
  final String email;

  RatingPage({required this.email});
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  int assignedPoints = 0;
  String rateService = '';
  File? _userImage;

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _userImage = File(pickedFile.path);
      });
    }
  }

  void rateMyService(String rating) {
    // Store the rating in Firebase or your preferred database.
    _database.child("rate_my_service").push().set({
      "rating": rating,
      "timestamp": ServerValue.timestamp,
    });

    // Show a toast message to thank the user for feedback.
    Fluttertoast.showToast(
      msg: "Thank you for the valuable feedback!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 102, 240, 194),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150), // Adjust the height as needed
        child: AppBar(
          title: Row(
            children: [
              GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _userImage == null
                      ? AssetImage('assets/images/profile_Default.jpg')
                          as ImageProvider<Object>
                      : FileImage(_userImage!) as ImageProvider<Object>,
                ),
              ),
              Spacer(), // Add a spacer to separate the image and the name
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Name", style: TextStyle(fontSize: 18)),
                  Text(
                      "Additional Info or Description"), // Add any additional text
                ],
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 89, 187, 240),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Rest of the content
          ListTile(
            title: Text("Assign Points"),
          ),
          Divider(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RatingDetailsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Color.fromARGB(255, 89, 187, 240),
            ),
            child: Text("Please let us know how is your experience with us!"),
          ),
          Divider(),
          ListTile(
            title: Text("Rate My Service"),
          ),
          Divider(),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => rateMyService("excellent"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: Text("Excellent"),
              ),
              ElevatedButton(
                onPressed: () => rateMyService("good"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: Text("Good"),
              ),
              ElevatedButton(
                onPressed: () => rateMyService("bad"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.red,
                ),
                child: Text("Bad"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

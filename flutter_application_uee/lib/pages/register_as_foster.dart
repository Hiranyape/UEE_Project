import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class FosterRegistrationPage extends StatefulWidget {
  final String fosterEmail;
  final String? userEmail;

  FosterRegistrationPage({required this.fosterEmail, this.userEmail});
  @override
  _FosterRegistrationPageState createState() => _FosterRegistrationPageState();
}

class _FosterRegistrationPageState extends State<FosterRegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _fosterImage;
  String fosterAbout = '';
  String extraPoints = '';
  String fosterName = '';
  String fosterAge = '';
  String fosterSex = 'Male';
  String? userId;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fosterImage = File(pickedFile.path);
      });
    }
  }

  Future<void> submitFosterRegistration() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        userId = user.uid;
      }

      CollectionReference fostersCollection = _firestore.collection("fosters");
      List<String> extraPointsList =
          extraPoints.split('\n').map((point) => point.trim()).toList();
      await fostersCollection.add({
        "user_id": userId,
        "fosterEmail": widget
            .fosterEmail, // Use the email passed from the Foster Home page
        "image": _fosterImage != null ? _fosterImage!.path : null,
        "name": fosterName,
        "age": fosterAge,
        "sex": fosterSex,
        "about": fosterAbout,
        "extra_points": extraPointsList,
      });

      showSuccessMessage("Foster registration submitted successfully");
    } catch (error) {
      showErrorMessage("Error: $error");
    }
  }

  void showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 102, 240, 194),
      textColor: Colors.white,
    );
  }

  void showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Foster Registration"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _fosterImage != null
                      ? FileImage(_fosterImage!)
                      : AssetImage('assets/images/profile_Default.jpg')
                          as ImageProvider<Object>,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    fosterName = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    fosterAge = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Sex", style: TextStyle(fontSize: 16)),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: "Male",
                        groupValue: fosterSex,
                        onChanged: (value) {
                          setState(() {
                            fosterSex = "Male";
                          });
                        },
                      ),
                      Text("Male"),
                      Radio(
                        value: "Female",
                        groupValue: fosterSex,
                        onChanged: (value) {
                          setState(() {
                            fosterSex = "Female";
                          });
                        },
                      ),
                      Text("Female"),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "About the Foster",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    fosterAbout = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Extra Points (in point form)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    extraPoints = value;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: submitFosterRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

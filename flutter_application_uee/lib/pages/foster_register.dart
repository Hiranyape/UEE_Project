import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class FosterRegistrationPage extends StatefulWidget {
  @override
  _FosterRegistrationPageState createState() => _FosterRegistrationPageState();
}

class _FosterRegistrationPageState extends State<FosterRegistrationPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  File? _fosterImage;
  String fosterAbout = '';
  String extraPoints = '';
  String fosterName = '';
  int fosterAge = 0;
  String fosterSex = ''; // Add a variable to store the selected sex.

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fosterImage = File(pickedFile.path);
      });
    }
  }

  void submitFosterRegistration() {
    // Store the foster registration details in Firebase or your preferred database.
    _database.child("foster_registrations").push().set({
      "image": _fosterImage != null ? _fosterImage?.path : null,
      "name": fosterName,
      "age": fosterAge,
      "sex": fosterSex, // Use the selected sex.
      "about": fosterAbout,
      "extra_points": extraPoints,
      "timestamp": ServerValue.timestamp,
    });

    // Show a confirmation message to the user using FlutterToast.
    Fluttertoast.showToast(
      msg: "Foster registration submitted successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 102, 240, 194),
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
                    fosterAge = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            // Add the radio button selection for "Male" and "Female".
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
                            fosterSex = value as String;
                          });
                        },
                      ),
                      Text("Male"),
                      Radio(
                        value: "Female",
                        groupValue: fosterSex,
                        onChanged: (value) {
                          setState(() {
                            fosterSex = value as String;
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

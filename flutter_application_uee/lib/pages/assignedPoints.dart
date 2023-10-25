import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "rating_page.dart";

class RatingDetailsPage extends StatefulWidget {
  @override
  _RatingDetailsPageState createState() => _RatingDetailsPageState();
}

class _RatingDetailsPageState extends State<RatingDetailsPage> {
  int feedPoints = 0;
  int medicalPoints = 0;
  int walkingPoints = 0;
  int fosteringPoints = 0;
  bool submitted = false;

  // Initialize Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void submitRatings() async {
    try {
      // Store the points in Firebase
      await firestore.collection('ratings').add({
        'feedPoints': feedPoints,
        'medicalPoints': medicalPoints,
        'walkingPoints': walkingPoints,
        'fosteringPoints': fosteringPoints,
      });

      // After recording the points, show a success message
      setState(() {
        submitted = true;
      });

      // Show an AlertDialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Your feedback is valuable to us. Thank you for your time to share your thoughts with us !",
                  style: TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the rating page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RatingPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text("Dismiss"),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle errors and display an error toast message
      print("Error submitting ratings: $e");

      Fluttertoast.showToast(
        msg: "Error submitting ratings. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rating Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildSection("Feed", Icons.restaurant),
            buildSection("Medical and Health", Icons.local_hospital),
            buildSection("Walking", Icons.directions_walk),
            buildSection("Fostering", Icons.home),
            ElevatedButton(
              onPressed: submitted ? null : submitRatings,
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

  Widget buildSection(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  switch (title) {
                    case "Feed":
                      feedPoints = feedPoints > 0 ? feedPoints - 1 : 0;
                      break;
                    case "Medical and Health":
                      medicalPoints = medicalPoints > 0 ? medicalPoints - 1 : 0;
                      break;
                    case "Walking":
                      walkingPoints = walkingPoints > 0 ? walkingPoints - 1 : 0;
                      break;
                    case "Fostering":
                      fosteringPoints =
                          fosteringPoints > 0 ? fosteringPoints - 1 : 0;
                      break;
                  }
                });
              },
            ),
            Text(
              title == "Feed"
                  ? feedPoints.toString()
                  : title == "Medical and Health"
                      ? medicalPoints.toString()
                      : title == "Walking"
                          ? walkingPoints.toString()
                          : fosteringPoints.toString(),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  switch (title) {
                    case "Feed":
                      feedPoints++;
                      break;
                    case "Medical and Health":
                      medicalPoints++;
                      break;
                    case "Walking":
                      walkingPoints++;
                      break;
                    case "Fostering":
                      fosteringPoints++;
                      break;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

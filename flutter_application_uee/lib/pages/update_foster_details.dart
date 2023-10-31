import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateFosterPage extends StatefulWidget {
  final String fosterEmail;

  UpdateFosterPage({required this.fosterEmail});

  @override
  _UpdateFosterPageState createState() => _UpdateFosterPageState();
}

class _UpdateFosterPageState extends State<UpdateFosterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController extraPointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFosterDetails();
  }

  Future<void> fetchFosterDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('fosters')
          .where('fosterEmail', isEqualTo: widget.fosterEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot fosterDoc = querySnapshot.docs.first;
        nameController.text = fosterDoc['name'];
        ageController.text = fosterDoc['age'];
        sexController.text = fosterDoc['sex'];
        aboutController.text = fosterDoc['about'];
        extraPointsController.text = fosterDoc['extra_points'].join('\n');
      }
    } catch (e) {
      print("Error fetching foster details: $e");
    }
  }

  Future<void> updateFosterDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('fosters')
          .where('email', isEqualTo: widget.fosterEmail)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          value.docs.first.reference.update({
            'name': nameController.text,
            'age': ageController.text,
            'sex': sexController.text,
            'about': aboutController.text,
            'extra_points': extraPointsController.text.split('\n'),
          });
          // Show a success message using a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Details updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Foster Details"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          TextFormField(
            controller: ageController,
            decoration: InputDecoration(labelText: "Age"),
          ),
          TextFormField(
            controller: sexController,
            decoration: InputDecoration(labelText: "Sex"),
          ),
          TextFormField(
            controller: aboutController,
            decoration: InputDecoration(labelText: "About"),
          ),
          TextFormField(
            controller: extraPointsController,
            decoration:
                InputDecoration(labelText: "Extra Points (in point form)"),
            maxLines: 4,
          ),
          ElevatedButton(
            onPressed: updateFosterDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text("Update Details"),
          ),
        ],
      ),
    );
  }
}

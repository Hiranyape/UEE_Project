import 'package:flutter/material.dart';

class UpdateFosterDetailsPage extends StatefulWidget {
  final String fosterEmail;

  UpdateFosterDetailsPage({required this.fosterEmail});

  @override
  _UpdateFosterDetailsPageState createState() =>
      _UpdateFosterDetailsPageState();
}

class _UpdateFosterDetailsPageState extends State<UpdateFosterDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController extraPointsController = TextEditingController();

  // You can define an image variable to display the image.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Foster Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Display the image here.

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: aboutController,
                decoration: InputDecoration(labelText: 'About'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter something about yourself';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: extraPointsController,
                decoration: InputDecoration(labelText: 'Extra Points'),
                // You can customize this field as needed.
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform the update operation here using the user's input.
                    // You can use widget.fosterEmail to identify the user.
                    // Display a success toast message.
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

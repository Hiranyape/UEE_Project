import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/register_as_foster.dart';
import 'package:flutter_application_uee/pages/update_foster_details.dart';

class FosterProfilePage extends StatelessWidget {
  final String fosterEmail;

  FosterProfilePage({required this.fosterEmail});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Foster Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Foster Email: $fosterEmail"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FosterRegistrationPage(
                      fosterEmail: fosterEmail,
                    ),
                  ),
                );
              },
              child: Text("Add Foster Details"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateFosterPage(fosterEmail: fosterEmail),
                  ),
                );
              },
              child: Text("Update My Foster Details"),
            ),
          ],
        ),
      ),
    );
  }
}

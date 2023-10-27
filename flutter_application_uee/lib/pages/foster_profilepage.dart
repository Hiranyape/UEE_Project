import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Foster Email: $fosterEmail",
                style: TextStyle(fontSize: 18)),
          ),
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
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Text("My Ratings and Rewards", style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: MyRatingsAndRewards(fosterEmail: fosterEmail),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Notifications", style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: MyNotifications(fosterEmail: fosterEmail),
          ),
        ],
      ),
    );
  }
}

class MyNotifications extends StatefulWidget {
  final String fosterEmail;

  MyNotifications({required this.fosterEmail});

  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('fosterRequests')
        .where('fosterEmail', isEqualTo: widget.fosterEmail)
        .where('status', isEqualTo: 'pending') // Filter for pending requests
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No pending requests."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final requestDoc = snapshot.data!.docs[index];
            final currentUserEmail = requestDoc['currentUserEmail'];
            final requestId = requestDoc.id;
            final status = requestDoc['status'];

            return Card(
              elevation: 3,
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text("Request from: $currentUserEmail"),
                subtitle: Text("Status: $status"),
                trailing: status == 'pending'
                    ? ElevatedButton(
                        onPressed: () {
                          // Accept the request and send an email notification
                          toggleRequestStatus(requestId, 'accept');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text("Accept"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          // Cancel the request and send an email notification
                          toggleRequestStatus(requestId, 'pending');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text("Cancel"),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> toggleRequestStatus(String requestId, String newStatus) async {
    try {
      // Update the request status
      await FirebaseFirestore.instance
          .collection('fosterRequests')
          .doc(requestId)
          .update({'status': newStatus});

      // Send an email notification to currentUserEmail
      // You can implement email notifications using a suitable service.

      // Optionally, you can also show a success message.
      showSuccessMessage(newStatus == 'accept'
          ? "Request accepted successfully"
          : "Request canceled successfully");
    } catch (error) {
      // Handle any errors
      showErrorMessage("Error updating request status: $error");
    }
  }

  void showSuccessMessage(String message) {
    // Implement a success message display mechanism (e.g., SnackBar or FlutterToast).
  }

  void showErrorMessage(String message) {
    // Implement an error message display mechanism (e.g., SnackBar or FlutterToast).
  }
}

class MyRatingsAndRewards extends StatelessWidget {
  final String fosterEmail;

  MyRatingsAndRewards({required this.fosterEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: fetchRatingsAndRewards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;

          if (data.isEmpty) {
            return Center(child: Text("No ratings and rewards yet."));
          }

          return Card(
            elevation: 3,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Feed Points: ${data['feedPoints'] ?? 0}"),
                  Text("Medical Points: ${data['medicalPoints'] ?? 0}"),
                  Text("Walking Points: ${data['walkingPoints'] ?? 0}"),
                  Text("Fostering Points: ${data['fosteringPoints'] ?? 0}"),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("No data available."));
        }
      },
    );
  }

  Future<Map<String, int>> fetchRatingsAndRewards() async {
    try {
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('email',
              isEqualTo: fosterEmail) // Use 'email' to match the fosterEmail
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        final data = ratingsSnapshot.docs.first.data() as Map<String, dynamic>;

        // Access nested fields with default values
        final feedPoints = data['feedPoints'] ?? 0;
        final fosteringPoints = data['fosteringPoints'] ?? 0;
        final medicalPoints = data['medicalPoints'] ?? 0;
        final walkingPoints = data['walkingPoints'] ?? 0;

        return {
          'feedPoints': feedPoints,
          'fosteringPoints': fosteringPoints,
          'medicalPoints': medicalPoints,
          'walkingPoints': walkingPoints,
        };
      } else {
        return {
          'feedPoints': 0,
          'fosteringPoints': 0,
          'medicalPoints': 0,
          'walkingPoints': 0,
        };
      }
    } catch (error) {
      print("Error fetching ratings and rewards: $error");
      return {
        'feedPoints': 0,
        'fosteringPoints': 0,
        'medicalPoints': 0,
        'walkingPoints': 0,
      };
    }
  }
}

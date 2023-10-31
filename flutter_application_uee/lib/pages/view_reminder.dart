import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_reminder.dart'; 

class ViewReminderPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> reminder;

  ViewReminderPage({required this.reminder});

  Future<void> _deleteReminder(BuildContext context) async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this reminder?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the delete
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Store the deleted reminder in the "cancelled reminders" collection
                Map<String, dynamic> cancelledReminderData = {
                  'title': reminder['title'],
                  'description': reminder['description'],
                  'dateTime': reminder['dateTime'],
                  // You can add more fields as needed
                };

                // Add the deleted reminder to the "cancelled reminders" collection
                await FirebaseFirestore.instance
                    .collection('cancelled_reminders') // Change to your collection name
                    .add(cancelledReminderData);

                // Delete the reminder from the "reminders" collection
                await FirebaseFirestore.instance
                    .collection('reminders')
                    .doc(reminder.id)
                    .delete();

                Navigator.of(context).pop(true); // Confirm the delete
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    // Delete the reminder if confirmed
    if (confirmDelete == true) {
      Navigator.of(context).pop(); // Close the view reminder page
    }

  }

  void _editReminder(BuildContext context) {
    // Navigate to the EditReminderPage with the reminder data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminder: reminder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var title = reminder['title'];
    var description = reminder['description'];
    var dateTime = reminder['dateTime'].toDate();

    // Format date and time
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text("View Reminder"),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "Date: $formattedDate",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            Text(
              "Time: $formattedTime",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 32.0),
            Spacer(), // Add spacer to push buttons to the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _editReminder(context); // Navigate to edit page
                  },
                  icon: Icon(Icons.edit),
                  label: Text(""), // Empty text label
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _deleteReminder(context); // Call delete function
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  icon: Icon(Icons.delete),
                  label: Text(""), // Empty text label
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_reminder.dart'; // Import your CreateReminderPage here
import 'view_reminder.dart'; // Import your ViewReminderPage here
import 'package:intl/intl.dart'; // Import the intl package for date and time formatting

class MyRemindersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Reminders"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReminderList(),
          ),
          SizedBox(height: 16.0), // Add some spacing
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the CreateReminderPage when the FAB is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateReminderPage(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ReminderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('reminders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var reminders = snapshot.data?.docs;

        if (reminders == null || reminders.isEmpty) {
          return Center(
            child: Text("No reminders found."),
          );
        }

        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            var reminder = reminders[index];
            var title = reminder['title'];
            var description = reminder['description'];
            var dateTime = reminder['dateTime'].toDate();

            // Format date and time
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            String formattedTime = DateFormat('hh:mm a').format(dateTime);

            return GestureDetector(
              onTap: () {
                // Navigate to the ViewReminderPage when the reminder is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewReminderPage(reminder: reminder),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 145, 194, 244),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: const Color.fromARGB(255, 25, 25, 25),
                      ),
                    ),
                    SizedBox(height: 8.0), // Added spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date: $formattedDate",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 48, 43, 43),
                          ),
                        ),
                        Text(
                          "Time: $formattedTime",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: const Color.fromARGB(255, 48, 43, 43),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

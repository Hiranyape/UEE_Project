import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import './create_reminder.dart'; 
import './view_reminder.dart';

class OngoingRemindersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Reminders"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(text: "Completed"),
              Tab(text: "Pending"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OngoingReminderList(status: "today"),
            OngoingReminderList(status: "completed"),
            OngoingReminderList(status: "pending"),
            CancelledReminderList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the CreateReminderPage when the plus button is pressed
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

class CancelledReminderList extends StatelessWidget {
   // Function to delete a cancelled reminder
    Future<void> _deleteCancelledReminder(BuildContext context, DocumentSnapshot cancelledReminder) async {
      await FirebaseFirestore.instance
          .collection('cancelled_reminders')
          .doc(cancelledReminder.id)
          .delete();
    }
    @override
    Widget build(BuildContext context) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cancelled_reminders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var cancelledReminders = snapshot.data?.docs;

          if (cancelledReminders == null || cancelledReminders.isEmpty) {
            return Center(
              child: Text("No cancelled reminders found."),
            );
          }

          return ListView.builder(
            itemCount: cancelledReminders.length,
            itemBuilder: (context, index) {
              var cancelledReminder = cancelledReminders[index];
              var title = cancelledReminder['title'];
              var description = cancelledReminder['description'];
              var dateTime = cancelledReminder['dateTime'].toDate();

              // Format date and time
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              String formattedTime = DateFormat('hh:mm a').format(dateTime);

              return GestureDetector(
                onTap: () {
                  // Navigate to the ViewReminderPage when a reminder is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewReminderPage(reminder: cancelledReminder),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 228, 167, 163),
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
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date: $formattedDate",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          Text(
                            "Time: $formattedTime",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Call the delete function when the button is pressed
                          _deleteCancelledReminder(context, cancelledReminder);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        icon: Icon(Icons.delete),
                        label: Text(""),
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
class OngoingReminderList extends StatelessWidget {
  final String status;

  OngoingReminderList({required this.status});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);
    DateTime todayEnd = todayStart.add(Duration(days: 1));

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
            child: Text("No reminders found for $status."),
          );
        }

        // Filter reminders based on the selected status
        var filteredReminders = reminders.where((reminder) {
          var dateTime = reminder['dateTime'].toDate();
          if (status == "today") {
            return dateTime.isAfter(todayStart) && dateTime.isBefore(todayEnd);
          } else if (status == "completed") {
            return dateTime.isBefore(todayStart);
          } else if (status == "pending") {
            return dateTime.isAfter(todayEnd);
          } else if (status == "cancelled") {
            return false;
          }
          return false;
        }).toList();

        if (filteredReminders.isEmpty) {
          return Center(
            child: Text("No reminders found for $status."),
          );
        }

        return ListView.builder(
          itemCount: filteredReminders.length,
          itemBuilder: (context, index) {
            var reminder = filteredReminders[index];
            var title = reminder['title'];
            var description = reminder['description'];
            var dateTime = reminder['dateTime'].toDate();

            // Format date and time
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            String formattedTime = DateFormat('hh:mm a').format(dateTime);

            return GestureDetector(
              onTap: () {
                // Navigate to the ViewReminderPage when a reminder is clicked
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
                    SizedBox(height: 8.0),
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
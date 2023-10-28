import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the FlutterLocalNotificationsPlugin
import 'my_reminders.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;


class CreateReminderPage extends StatefulWidget {
  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reminder Details",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Text(
                        "${selectedDateTime.toLocal()}".split(' ')[0],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                      ),
                      child: Text(
                        "${selectedDateTime.toLocal().toLocal()}".split(' ')[1].split(':')[0] +
                            ":" +
                            "${selectedDateTime.toLocal().toLocal()}".split(' ')[1].split(':')[1],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveReminder,
        child: Icon(Icons.save),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDateTime) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void saveReminder() {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      // Show an error message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title and description.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    CollectionReference reminders =
        FirebaseFirestore.instance.collection('reminders');

    reminders
        .add({
          'title': title,
          'description': description,
          'dateTime': selectedDateTime,
        })
        .then((value) {
          // Calculate the notification time (15 minutes before the selectedDateTime)
          final notificationTime = selectedDateTime.subtract(Duration(minutes: 15));

          // Schedule the notification
          scheduleNotification(notificationTime);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyRemindersPage(),
          ));
        })
        .catchError((error) {});
  }

  void scheduleNotification(DateTime notificationTime) async {
    tzdata.initializeTimeZones(); // Initialize time zones
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Define the Android notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'my_notification', 
      'Scheduled Notifications',
      importance: Importance.max,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create a TZDateTime using the timezone package
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(notificationTime, tz.local);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Unique ID for the notification
      'Reminder', // Notification title
      'Event in 15 minutes', // Notification body
      scheduledTime, // Scheduled time using TZDateTime
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

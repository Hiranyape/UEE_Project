import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'my_reminders.dart'; 
import 'package:intl/intl.dart'; 

class EditReminderPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> reminder;

  EditReminderPage({required this.reminder});

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late DateTime selectedDateTime; // Use 'late' keyword to mark it as non-nullable

  @override
  void initState() {
    super.initState();

    // Initialize the fields with existing data
    titleController.text = widget.reminder['title'];
    descriptionController.text = widget.reminder['description'];
    selectedDateTime = widget.reminder['dateTime'].toDate();
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

  void updateReminder() {
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
        .doc(widget.reminder.id) 
        .update({
          'title': title,
          'description': description,
          'dateTime': selectedDateTime,
        })
        .then((value) {
          // Successfully updated reminder in Firestore
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyRemindersPage(), // Navigate to My Reminders page
          ));
        })
        .catchError((error) {
        });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
    String formattedTime = DateFormat('hh:mm a').format(selectedDateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Reminder Details",
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
                        formattedDate,
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
                        formattedTime,
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
        onPressed: updateReminder,
        child: Icon(Icons.save),
      ),
    );
  }
}

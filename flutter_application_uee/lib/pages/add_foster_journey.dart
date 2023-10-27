import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/components/form_feild_text.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class AddFosterJorney extends StatefulWidget {
  final Function()? onTap;
  final QueryDocumentSnapshot petDocument;

  const AddFosterJorney({super.key, required this.onTap,required this.petDocument});

  @override
  State<AddFosterJorney> createState() => _AddFosterJorneyState();
}

class _AddFosterJorneyState extends State<AddFosterJorney> {
  final title = TextEditingController();
  final description = TextEditingController();
  String? selectedImagePath;
  String? file;
  late Cloudinary cloudinary;
  

  Future<void> uploadImage(String imagePath) async {
    try {
      final apiUrl = 'https://api.cloudinary.com/v1_1/daxiby67v/image/upload';
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['upload_preset'] = 'y2ci3cny';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = json.decode(responseString);

        final imageUrl = jsonMap['secure_url'];

        setState(() {
          selectedImagePath = imageUrl;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = image.path;
        selectedImagePath = image.path;
      });
    }
  }

  void addJourney() async {
    // Show loading circle.
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> postJourney() async {
  if (title.text.isNotEmpty || description.text.isNotEmpty) {
    if (selectedImagePath != null) {
      await uploadImage(selectedImagePath!);
      final petDocumentSnapshot = await FirebaseFirestore.instance.collection("Pets").doc(widget.petDocument.id).get(); // Re-fetch the pet document
      final List<DocumentReference> journeyRefs = List<DocumentReference>.from(petDocumentSnapshot['JourneyTracker']);
      final newJourneyRef = await FirebaseFirestore.instance.collection("JourneyTracker").add({
        'UserEmail': petDocumentSnapshot['Owner'],
        'Description': description.text,
        'Title': title.text,
        'Image': selectedImagePath,
        'TimeStamp': FieldValue.serverTimestamp(),
      });

      journeyRefs.add(newJourneyRef);
      
      // Update the pet document with the updated JourneyTracker
      await FirebaseFirestore.instance.collection("Pets").doc(widget.petDocument.id).update({'JourneyTracker': journeyRefs});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journey added successfully.'),
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFF0099CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );

      setState(() {
        title.text = '';
        description.text = '';
        selectedImagePath = null;
        file = null;
      });

      Navigator.of(context).pop();
    } else {
      print("Please select an image.");
    }
  } else {
    print("Title and description are empty.");
  }
}

  


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Journey"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          GestureDetector(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            width: screenWidth - 50,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: file != null
                  ? Image.file(
                      File(file!),
                      fit: BoxFit.cover,
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_a_photo, 
                          size: 40,
                          color: Colors.grey,
                        ),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  MyTextFormFeild(
                    controller: title,
                    hintText: 'Title',
                  ),
                  const SizedBox(height: 10),
                  MyTextFormFeild(
                    controller: description,
                    hintText: 'Description',
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 25),
                  MyButton(onTap: postJourney, text: 'Add A New Journey'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

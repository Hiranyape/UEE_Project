import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/components/form_feild_text.dart';
import 'package:flutter_application_uee/components/text_feild.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterMyPetPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterMyPetPage({super.key, required this.onTap});

  @override
  State<RegisterMyPetPage> createState() => _RegisterMyPetPageState();
}

class _RegisterMyPetPageState extends State<RegisterMyPetPage> {
  final describe = TextEditingController();
  final name = TextEditingController();
  final breed = TextEditingController();
  final weight = TextEditingController();
  final age = TextEditingController();
  final specialnotes = TextEditingController();
  String? selectedImagePath; 
  String? file;// To store the selected image path.

  final currentUser = FirebaseAuth.instance.currentUser;

  void addJourney() async {
    // Show loading circle.
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void postJourney() async {
  if (describe.text.isNotEmpty ||
      name.text.isNotEmpty ||
      breed.text.isNotEmpty ||
      age.text.isNotEmpty ||
      weight.text.isNotEmpty ||
      specialnotes.text.isNotEmpty) {
      
      await uploadImage(selectedImagePath!);
    await FirebaseFirestore.instance.collection("Pets").add({
      'Owner': currentUser?.email,
      'Description': describe.text,
      'Name': name.text,
      'Breed': breed.text,
      'Age': age.text,
      'Weight': weight.text,
      'Specialnotes': specialnotes.text,
      'Image': selectedImagePath, // Store the Cloudinary image URL.
      'TimeStamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pet is added.'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
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
      describe.text = '';
      name.text = '';
      breed.text = '';
      age.text = '';
      weight.text = '';
      specialnotes.text = '';
      selectedImagePath = null;
      file=null;
    });
  }
}


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
      
    }
  } catch (e) {
  }
}

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  // Function to handle image selection.
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
        file=image.path; // Store the selected image path.
      });
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text("Add New Pet"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Add New Journey",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: _pickImage,
                    iconSize: 48, // Adjust the size as needed.
                  ),
                  // Display the selected image, if available.
                  if (selectedImagePath != null)
                    Image.file(File(selectedImagePath!)),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: describe,
                    hintText: 'Describe your fur baby in one sentence',
                    
                  ),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: name,
                    hintText: 'Name',
                   
                  ),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: breed,
                    hintText: 'Breed', // Use 'breed' controller
                    
                  ),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: weight,
                    hintText: 'Weight', // Use 'weight' controller
                    
                  ),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: age,
                    hintText: 'Age', // Use 'age' controller
                    
                  ),
                  const SizedBox(height: 20),
                  MyTextFormFeild(
                    controller: specialnotes,
                    hintText: 'Special Notes', // Use 'specialnotes' controller
                  ),
                  const SizedBox(height: 20),
                  MyButton(onTap: postJourney, text: 'Register'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

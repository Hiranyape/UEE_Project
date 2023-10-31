import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/register_my_pet.dart';

class Pet {
  final String? name;
  final String? description;
  final String? imageUrl;

  Pet({
    this.name,
    this.description,
    this.imageUrl,
  });
}

class UserProfile extends StatefulWidget {
  final String userEmail; // Pass the user's email when creating an instance

  UserProfile({required this.userEmail});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String selectedImagePath = '';
  List<Pet> petList = []; // List to store pets

  @override
  void initState() {
    super.initState();
    fetchAndDisplayPets(); // Fetch and display user's pets
  }

  void navigateToFosterLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterMyPetPage(onTap: () {  },),
      ),
    );
  }

  Future<void> fetchAndDisplayPets() async {
    // Fetch pets from Firebase Firestore based on user's email
    final petQuery = FirebaseFirestore.instance
        .collection("Pets")
        .where('Owner', isEqualTo: widget.userEmail)
        .get();

    final petDocs = (await petQuery).docs;

    final pets = petDocs.map((petDoc) {
      final data = petDoc.data() as Map<String, dynamic>;
      return Pet(
        name: data['Name'],
        description: data['Description'],
        imageUrl: data['Image'],
      );
    }).toList();

    setState(() {
      petList = pets; // Update the pet list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0099CD),
                ),
                width: MediaQuery.of(context).size.width,
                height: 140,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    selectedImagePath.isNotEmpty
                        ? Image.asset(
                            selectedImagePath,
                            width: 100,
                            height: 100,
                          )
                        : const Icon(
                            Icons.account_circle,
                            size: 100,
                            color: Colors.white,
                          ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Handle image editing
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.userEmail}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10), // Add spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Pets",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            navigateToFosterLogin();
                          },
                          style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                            ),
                          ),
                        ),
                          child: Text("Add Pet"),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: petList.length,
                      itemBuilder: (context, index) {
                        // Return a widget to display each pet in the list
                        return ListTile(
                          title: Text(petList[index].name ?? 'No Name'),
                          subtitle: Text(petList[index].description ?? 'No Description'),
                          // Add pet image if available
                          leading: petList[index].imageUrl != null
                              ? Image.network(petList[index].imageUrl!)
                              : Icon(Icons.pets),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

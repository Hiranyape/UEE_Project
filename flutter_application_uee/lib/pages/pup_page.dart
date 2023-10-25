import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/journey_tracker_list.dart';

class PetProfilePage extends StatelessWidget {
  final DocumentSnapshot petDocument;

  PetProfilePage({
    required this.petDocument,
  });

  @override
  Widget build(BuildContext context) {
    // Extract pet details from the document
    final name = petDocument['Name'] ?? 'No Name';
    final description = petDocument['Description'] ?? 'No Description';
    final imageUrl = petDocument['Image'];
    final age = petDocument["Age"];
    final weight = petDocument["Weight"];
    final breed = petDocument["Breed"];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
                Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0099CD),
                ),
                width: 380,
                height: 140,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    OverflowBox(
                      maxHeight: double.infinity,
                      minHeight: 0,
                      alignment: Alignment(0, 3),  // Adjust the alignment
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageUrl != null
                                ? CachedNetworkImageProvider(imageUrl)
                                : AssetImage('assets/default_image.jpg') as ImageProvider<Object>,
                          ),
                        ),
                      ),
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
                    Text(description),
                    SizedBox(height: 20),
                    const Text(
                      "Age",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(age ?? 'N/A'),
                    SizedBox(height: 20),
                    const Text(
                      "Weight",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(weight ?? 'N/A'),
                    SizedBox(height: 20),
                    const Text(
                      "Breed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(breed ?? 'N/A'),
                    SizedBox(height: 20),
                   MyButton(onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetJourneyTracker(petDocument: petDocument as QueryDocumentSnapshot),
                      ),
                    );
                  }, text: 'Add New Journey'),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetJourneyTracker extends StatelessWidget {
  final QueryDocumentSnapshot petDocument;

  PetJourneyTracker({required this.petDocument});

  @override
  Widget build(BuildContext context) {
    final List<DocumentReference> journeyRefs = (petDocument['JourneyTracker'] as List)
        .map((ref) => ref as DocumentReference)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Journey Tracker'),
      ),
      body: ListView.builder(
        itemCount: journeyRefs.length,
        itemBuilder: (context, index) {
          final journeyRef = journeyRefs[index];

          return FutureBuilder<DocumentSnapshot>(
            future: journeyRef.get(),
            builder: (context, journeySnapshot) {
              if (journeySnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (journeySnapshot.hasError) {
                return Text('Error: ${journeySnapshot.error}');
              } else if (!journeySnapshot.hasData) {
                return Text('Journey data not found');
              }

              final journeyData = journeySnapshot.data!.data() as Map<String, dynamic>;
              final title = journeyData['Title'] ?? 'No Title';
              final description = journeyData['Description'] ?? 'No Description';
              final imageUrl = journeyData['Image'];
              
              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

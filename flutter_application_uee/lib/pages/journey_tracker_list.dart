import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/add_foster_journey.dart';

class PetJourneyTracker extends StatefulWidget {
  final QueryDocumentSnapshot petDocument;

  PetJourneyTracker({required this.petDocument});

  @override
  _PetJourneyTrackerState createState() => _PetJourneyTrackerState();
}

class _PetJourneyTrackerState extends State<PetJourneyTracker> {
  final List<DocumentReference> journeyRefs = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await widget.petDocument.reference.get();
    final newJourneyRefs = (data['JourneyTracker'] as List)
        .map((ref) => ref as DocumentReference)
        .toList();

    setState(() {
      journeyRefs.clear();
      journeyRefs.addAll(newJourneyRefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journey Tracker'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
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
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Column(
                            children: [
                              imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 100,
                                      color: Colors.grey,
                                    ),
                              ListTile(
                                title: Text(title),
                                subtitle: Text(description),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "Add New Journey" page
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddFosterJorney(onTap: fetchData, petDocument: widget.petDocument);
                  },
                ),
              )
              .then((_) {
            fetchData();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

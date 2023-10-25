import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinic_backend.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinics_single_page.dart';

class VetClinicBookmarksPage extends StatefulWidget {
  const VetClinicBookmarksPage({super.key});

  @override
  State<VetClinicBookmarksPage> createState() => _VetClinicBookmarksPageState();
}

class _VetClinicBookmarksPageState extends State<VetClinicBookmarksPage> {
  final Stream<QuerySnapshot> collectionReference =
      FirebaseCrudVetClinic.getVetClinics();

  void navigateToVetClinicSinglePage(String documentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VetClinicSinglePage(documentId: documentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionReference,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Data is available
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  for (var vetClinic in snapshot.data!.docs)
                    GestureDetector(
                      onTap: () {
                        // Pass the document ID to the navigation function
                        navigateToVetClinicSinglePage(vetClinic.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(vetClinic['name']),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // An error occurred
            return Text('Error: ${snapshot.error}');
          } else {
            // Data is loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

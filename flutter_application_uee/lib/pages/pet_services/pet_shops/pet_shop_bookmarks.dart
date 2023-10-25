import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_backend.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_single_page.dart';

class PetShopBookmarksPage extends StatefulWidget {
  const PetShopBookmarksPage({super.key});

  @override
  State<PetShopBookmarksPage> createState() => _PetShopBookmarksPageState();
}

class _PetShopBookmarksPageState extends State<PetShopBookmarksPage> {
  final Stream<QuerySnapshot> collectionReference =
      FirebaseCrudPetShop.getPetShops();

  void navigateToPetShopSinglePage(String documentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PetShopSinglePage(documentId: documentId),
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
                  for (var petShop in snapshot.data!.docs)
                    GestureDetector(
                      onTap: () {
                        // Pass the document ID to the navigation function
                        navigateToPetShopSinglePage(petShop.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(petShop['name']),
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

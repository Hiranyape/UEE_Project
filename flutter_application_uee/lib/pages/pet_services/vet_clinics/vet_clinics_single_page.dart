import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_search_page.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinic_backend.dart';
import 'package:url_launcher/url_launcher.dart';

class VetClinicSinglePage extends StatefulWidget {
  final String documentId;
  VetClinicSinglePage({required this.documentId});

  @override
  State<VetClinicSinglePage> createState() => _VetClinicSinglePageState();
}

class _VetClinicSinglePageState extends State<VetClinicSinglePage> {
  // Replace these placeholders with actual data
  String shopName = "";
  String address = "";
  String contactNo = "";
  String websiteLink = "";

  void navigateToVetClinicSearchPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetShopSearchPage(),
      ),
    );
  }

  void returnToPreviousPage() {
    Navigator.of(context)
        .pop(); // This line will pop the current page and return to the previous page.
  }

  void deletePetShopWithConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this vet clinic?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseCrudVetClinic.deleteVetClinics(widget.documentId);
                Navigator.of(context).pop(); // Close the confirmation dialog
                returnToPreviousPage(); // Return to the previous page
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch pet shop details by document ID
    FirebaseCrudVetClinic.getVetClinicById(widget.documentId)
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          shopName = snapshot['name'];
          address = snapshot['address'];
          contactNo = snapshot['contact'];
          websiteLink = snapshot['website'];
        });
      }
    }).catchError((error) {
      print("Error fetching pet shop details: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vet Clinic"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            // Center the content vertically and horizontally
            child: Container(
              alignment:
                  Alignment.center, // Center both horizontally and vertically
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  // Square Image (Replace Image.network with your image source)
                  Container(
                    width: 100, // Adjust the size as needed
                    height: 100, // Adjust the size as needed
                    decoration: const BoxDecoration(
                      color: Colors.grey, // Placeholder color
                    ),
                    child: const ClipRect(
                      child: Image(
                        image: AssetImage('assets/images/petShop.png'),
                        width: 300, // Adjust the width to your preference
                        height: 200, // Adjust the height to your preference
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 16), // Add some space between image and fields
                  // Shop Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Shop Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(shopName),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Address
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Address: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(address),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Contact No
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Contact No: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchPhone(
                              contactNo); // Call the function to open the phone app
                        },
                        child: Text(
                          contactNo,
                          style: TextStyle(
                            color: Colors
                                .blue, // Change the text color to indicate it's a link
                            decoration: TextDecoration
                                .underline, // Add an underline to indicate it's clickable
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Website Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Website Link: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(websiteLink),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Delete and View Buttons in the same line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          deletePetShopWithConfirmation(); // Call the function to return to the previous page
                        },
                        child: const Text('Delete'),
                      ),
                      const SizedBox(
                          width: 16), // Add some space between buttons
                      ElevatedButton(
                        onPressed: navigateToVetClinicSearchPage,
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    } else {
      print('Could not launch $phoneLaunchUri');
    }
  }
}

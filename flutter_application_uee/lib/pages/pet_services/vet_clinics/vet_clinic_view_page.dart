import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinic_search_page.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinics_bookmarks.dart';

class VetClinicViewPage extends StatefulWidget {
  const VetClinicViewPage({super.key});

  @override
  State<VetClinicViewPage> createState() => _VetClinicViewPageState();
}

class _VetClinicViewPageState extends State<VetClinicViewPage> {
  void navigateToVetClinicSearchPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VetClinicSearchPage(),
      ),
    );
  }

  void navigateToVetClinicBookmarksPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VetClinicBookmarksPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: MyButton(
                        onTap: navigateToVetClinicSearchPage,
                        text: 'Search Vet Clinics'),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: MyButton(
                        onTap: navigateToVetClinicBookmarksPage,
                        text: 'Vet Clinic Bookmarks'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shop_single_page.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shop_view_page.dart';

class PetServicesPage extends StatefulWidget {
  const PetServicesPage({super.key});

  @override
  State<PetServicesPage> createState() => _PetServicesPageState();
}

class _PetServicesPageState extends State<PetServicesPage> {
  void navigateToPetShopViewPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetShopViewPage(),
      ),
    );
  }

  void navigateToPetShopMapPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetShopViewPage(),
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
                  const SizedBox(height: 40),
                  const Center(
                    child: ClipRect(
                      child: Image(
                        image: AssetImage('assets/images/startimg.jpg'),
                        width: 300, // Adjust the width to your preference
                        height: 200, // Adjust the height to your preference
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                      onTap: navigateToPetShopViewPage, text: 'Pet Stores'),
                  const SizedBox(height: 10),
                  const Center(
                    child: ClipRect(
                      child: Image(
                        image: AssetImage('assets/images/startimg.jpg'),
                        width: 300, // Adjust the width to your preference
                        height: 200, // Adjust the height to your preference
                      ),
                    ),
                  ),
                  MyButton(
                      onTap: navigateToPetShopMapPage, text: 'Pet Clinics'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

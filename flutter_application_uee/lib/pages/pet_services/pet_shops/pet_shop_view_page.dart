import 'package:flutter/material.dart';
import 'package:flutter_application_uee/components/button.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_bookmarks.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_search_page.dart';

class PetShopViewPage extends StatefulWidget {
  const PetShopViewPage({super.key});

  @override
  State<PetShopViewPage> createState() => _PetShopViewPageState();
}

class _PetShopViewPageState extends State<PetShopViewPage> {
  void navigateToPetShopSearchPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetShopSearchPage(),
      ),
    );
  }

  void navigateToPetBookmarksPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetShopBookmarksPage(),
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
                        onTap: navigateToPetShopSearchPage,
                        text: 'Search Pet Stores'),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: MyButton(
                        onTap: navigateToPetBookmarksPage,
                        text: 'Pet Shop Bookmarks'),
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

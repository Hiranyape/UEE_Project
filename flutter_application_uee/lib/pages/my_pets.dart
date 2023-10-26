import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_uee/pages/my_pet_journey_tracker.dart';

class Pet {
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? age;
  final String? breed;

  Pet({
    this.name,
    this.description,
    this.imageUrl,
    this.age,
    this.breed,
  });
}

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({Key? key}) : super(key: key);

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();
  List<Pet> petList = [];

  @override
  void initState() {
    super.initState();
    fetchAndDisplayPets();
  }

  Future<void> fetchAndDisplayPets() async {
    final petQuery = FirebaseFirestore.instance
        .collection("Pets")
        .where('Owner', isEqualTo: currentUser?.email)
        .get();

    final petDocs = (await petQuery).docs;

    final pets = petDocs.map((petDoc) {
      final data = petDoc.data() as Map<String, dynamic>;
      return Pet(
        name: data['Name'],
        description: data['Description'],
        imageUrl: data['Image'],
        age: data['Age'],
        breed: data['Breed'],
      );
    }).toList();

    setState(() {
      petList = pets;
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void searchPets(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchAndDisplayPets();
      } else {
        final filteredPets = petList.where((pet) {
          final name = pet.name?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
        petList = filteredPets;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Pets',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    onChanged: (query) {
                      searchPets(query);
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: petList.map((pet) {
                      return GestureDetector(
                        onTap: () async {
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection("Pets")
                              .where('Name', isEqualTo: pet.name)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            final petDocument = querySnapshot.docs.first;
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyPetJourneyPage(petDocument: petDocument),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: pet.imageUrl != null
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: pet.imageUrl!,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                )
                              : SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.asset('assets/default_image.jpg'),
                                ),
                          title: Text(pet.name ?? 'No Name'),
                          subtitle: Text(pet.description ?? 'No Description'),
                        ),
                      );
                    }).toList(),
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

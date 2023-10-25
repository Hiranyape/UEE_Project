import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_uee/pages/pup_page.dart';


class Foster {
  final String? name;
  final String? description;
  final String? imageUrl;

  Foster({
    this.name,
    this.description,
    this.imageUrl,
  });
}

class MyFosterPage extends StatefulWidget {
  const MyFosterPage({Key? key}) : super(key: key);

  @override
  State<MyFosterPage> createState() => _MyFosterPageState();
}

class _MyFosterPageState extends State<MyFosterPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();
  List<Foster> fosterList = [];

  @override
  void initState() {
    super.initState();
    fetchAndDisplayFosters();
  }

  Future<void> fetchAndDisplayFosters() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: currentUser?.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final user = userDoc.docs.first;
      final fostersRefs = user['fosters'];
      final fosters = await fetchFosters(fostersRefs);

      setState(() {
        fosterList = fosters;
      });
    }
  }

  Future<List<Foster>> fetchFosters(List<dynamic> fosterRefs) async {
    final fosterList = <Foster>[];

    for (final DocumentReference fosterRef in fosterRefs) {
      final fosterDocSnapshot = await fosterRef.get();

      if (fosterDocSnapshot.exists) {
        final fosterData = fosterDocSnapshot.data() as Map<String, dynamic>;
        final imageUrl = fosterData['Image'];

        final foster = Foster(
          name: fosterData['Name'],
          description: fosterData['Description'],
          imageUrl: imageUrl,
        );
        fosterList.add(foster);
      }
    }

    return fosterList;
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void searchFosters(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchAndDisplayFosters();
      } else {
        final filteredFosters = fosterList.where((foster) {
          final name = foster.name?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
        fosterList = filteredFosters;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foster Pets"),
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
                      labelText: 'Search Fosters',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    onChanged: (query) {
                      searchFosters(query);
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: fosterList.map((foster) {
                      return GestureDetector(
                        onTap: () async {
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection("Pets")
                              .where('Name', isEqualTo: foster.name)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            final petDocument = querySnapshot.docs.first;
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetProfilePage(petDocument: petDocument),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: foster.imageUrl != null
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  
                                  child: CachedNetworkImage(
                                    imageUrl: foster.imageUrl!,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                )
                              : SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.asset('assets/default_image.jpg'),
                                ),
                          title: Text(foster.name ?? 'No Name'),
                          subtitle: Text(foster.description ?? 'No Description'),
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

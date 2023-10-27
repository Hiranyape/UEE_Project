import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPetJourneyPage extends StatefulWidget {
  final QueryDocumentSnapshot petDocument;

  MyPetJourneyPage({required this.petDocument});

  @override
  _MyPetJourneyPageState createState() => _MyPetJourneyPageState();
}

class _MyPetJourneyPageState extends State<MyPetJourneyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<DocumentReference> journeyRefs = [];
  List<DocumentSnapshot> journeySnapshots = [];
  List<bool> likedJourneys = [];
  String petOwnerEmail = ""; // Email of the pet owner
  String selectedFilter = "All"; // Default filter option

  @override
  void initState() {
    super.initState();
    fetchPetOwnerEmail();
    fetchData();
    initializeLikedJourneys();
  }

  Future<void> fetchPetOwnerEmail() async {
    final data = await widget.petDocument.reference.get();
    final petOwner = data['Owner'];
    setState(() {
      petOwnerEmail = petOwner;
    });
  }

  Future<void> initializeLikedJourneys() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail == petOwnerEmail) {
      // Fetch liked journeys from Firestore based on the user
      final likedJourneyDocs = await _firestore
          .collection('likedJourneys')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      final likedJourneyIds = likedJourneyDocs.docs
          .map((doc) => doc['journeyId'])
          .cast<String>()
          .toList();

      // Update the likedJourneys list based on the liked journey IDs
      setState(() {
        likedJourneys = journeyRefs
            .map((journeyRef) => likedJourneyIds.contains(journeyRef.id))
            .toList();
      });
    }
  }

  Future<void> toggleLike(int index) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail == petOwnerEmail) {
      setState(() {
        likedJourneys[index] = !likedJourneys[index];
      });

      // Update the backend to record the like
      if (likedJourneys[index]) {
        await _firestore.collection('likedJourneys').add({
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'journeyId': journeyRefs[index].id,
        });
      } else {
        // Remove the like from Firestore
        final likedJourneyDocs = await _firestore
            .collection('likedJourneys')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('journeyId', isEqualTo: journeyRefs[index].id)
            .get();

        for (final doc in likedJourneyDocs.docs) {
          await _firestore.collection('likedJourneys').doc(doc.id).delete();
        }
      }
    }
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

    // Fetch journey snapshots once
    final journeys = await Future.wait(journeyRefs.map((journeyRef) => journeyRef.get()));
    setState(() {
      journeySnapshots = journeys;
    });

    // Initialize liked journeys
    initializeLikedJourneys();
  }

  void filterJourneysByTimestamp(String? filter) {
    setState(() {
      selectedFilter = filter!;
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
            SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.filter_list, // You can change the icon to your preference
                  size: 32, // Adjust the icon size
                ),
                PopupMenuButton<String>(
                  offset: Offset(0, 50),
                  onSelected: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return ["All", "Last 7 Days", "Last 30 Days"].map((filter) {
                      return PopupMenuItem<String>(
                        value: filter,
                        child: Text(
                          filter,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Change the color to your preference
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: journeyRefs.length,
                itemBuilder: (context, index) {
                  if (index < journeySnapshots.length) {
                    final journeySnapshot = journeySnapshots[index];
                    final isLiked = likedJourneys.isNotEmpty ? likedJourneys[index] : false;
                    final journeyData = journeySnapshot.data() as Map<String, dynamic>;
                    final title = journeyData['Title'] ?? 'No Title';
                    final description = journeyData['Description'] ?? 'No Description';
                    final imageUrl = journeyData['Image'];
                    final timestamp = journeyData['TimeStamp'];

                  
                    final now = DateTime.now();
                    final last7Days = now.subtract(Duration(days: 7));
                    final last30Days = now.subtract(Duration(days: 30));
                    final timestampDate = (timestamp as Timestamp).toDate();
                    if (selectedFilter == "Last 7 Days" &&
                        !timestampDate.isAfter(last7Days)) {
                      return Container(); 
                    } else if (selectedFilter == "Last 30 Days" &&
                        !timestampDate.isAfter(last30Days)) {
                      return Container(); 
                    }

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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(description),
                                  SizedBox(height: 8),
                                  // Display the date and time in a user-friendly way
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormat('MMM d, y').format(timestampDate)}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () {
                                  toggleLike(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

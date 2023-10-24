import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_uee/pages/pet_services/models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _collection = _firestore.collection("PetShop");

class FirebaseCrud {
  static Future<Response> addPetShop(
    String name,
    String address,
    String contact,
    String website,
    double latitude,
    double longitude,
  ) async {
    Response response = Response();
    DocumentReference documentReference = _collection.doc();

    Map<String, dynamic> data = <String, dynamic>{
      "name": name,
      "address": address,
      "contact": contact,
      "website": website,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
      },
    };

    await documentReference.set(data).whenComplete(() {
      response.code = 200;
      response.message = "PetShop added successfully!";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Stream<QuerySnapshot> getPetShops() {
    CollectionReference petShopCollection = _collection;
    return petShopCollection.snapshots();
  }

  static Future<Response> deletePetShop(String docId) async {
    Response response = Response();
    DocumentReference documentReference = _collection.doc(docId);

    await documentReference.delete().whenComplete(() {
      response.code = 200;
      response.message = "PetShop deleted";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<Response> updatePetShop(
    String docId,
    String name,
    String address,
    String contact,
    String website,
    double latitude,
    double longitude,
  ) async {
    Response response = Response();
    DocumentReference documentReference = _collection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "name": name,
      "address": address,
      "contact": contact,
      "website": website,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
      },
    };

    await documentReference.update(data).whenComplete(() {
      response.code = 200;
      response.message = "PetShop updated!";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<DocumentSnapshot<Object?>> getPetShopById(String docId) async {
    DocumentReference documentReference = _collection.doc(docId);
    return await documentReference.get();
  }

  static Future<QuerySnapshot<Object?>> getPetShopByName(String name) async {
    return await _collection.where("name", isEqualTo: name).get();
  }
}

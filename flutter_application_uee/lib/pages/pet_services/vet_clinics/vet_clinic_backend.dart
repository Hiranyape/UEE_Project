import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_uee/pages/pet_services/models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _collection = _firestore.collection("VetClinic");

class FirebaseCrudVetClinic {
  static Future<Response> addVetClinic(
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
      response.message = "VetClinic added successfully!";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Stream<QuerySnapshot> getVetClinics() {
    CollectionReference vetClinicsCollection = _collection;
    return vetClinicsCollection.snapshots();
  }

  static Future<Response> deleteVetClinics(String docId) async {
    Response response = Response();
    DocumentReference documentReference = _collection.doc(docId);

    await documentReference.delete().whenComplete(() {
      response.code = 200;
      response.message = "VetClinic deleted";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<Response> updateVetClinic(
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
      response.message = "VetClinic updated!";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<DocumentSnapshot<Object?>> getVetClinicById(
      String docId) async {
    DocumentReference documentReference = _collection.doc(docId);
    return await documentReference.get();
  }

  static Future<QuerySnapshot<Object?>> getVetClinicByName(String name) async {
    return await _collection.where("name", isEqualTo: name).get();
  }
}

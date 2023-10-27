// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/pet_services/location_service.dart';
import 'package:flutter_application_uee/pages/pet_services/models/response.dart';
import 'package:flutter_application_uee/pages/pet_services/pet_shops/pet_shop_backend.dart';
import 'package:flutter_application_uee/pages/pet_services/vet_clinics/vet_clinic_backend.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VetClinicSearchPage extends StatefulWidget {
  const VetClinicSearchPage({super.key});

  @override
  State<VetClinicSearchPage> createState() => VetClinicSearchPageState();
}

class VetClinicSearchPageState extends State<VetClinicSearchPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  TextEditingController _originController = TextEditingController();

  TextEditingController _destinationController = TextEditingController();

  double selectedMarkerLat = 0.0;
  double selectedMarkerLng = 0.0;
  bool isBookmarked = false;
  String markerTitleName = "";
  IconData bookmarkIcon = Icons.bookmark_border; // Icon when not bookmarked

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polyline = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  String locationMessage = 'Current Location of the User';
  late String lat;
  late String long;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // Retrieve the current location upon launching the page
    _getCurrentLocation().then(
      (value) {
        lat = '${value.latitude}';
        long = '${value.longitude}';

        Marker _userLocationMarker = Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(value.latitude,
              value.longitude), // Use the user's latitude and longitude
          infoWindow: InfoWindow(
            title: 'Home', // Set the title text here
          ),
        );

        if (mounted) {
          setState(
            () {
              locationMessage = 'Latitude: $lat, Longitude: $long';
              // Set the current location to the _originController
              _originController.text = '$lat, $long';
              // _setMarker(LatLng(value.latitude, value.longitude));
              _markers.add(_userLocationMarker);
              _goToPlace(value.latitude, value.longitude, null, null);

              _getVetClinics();
            },
          );
        }
      },
    );
  }

  void _setMarker(LatLng point, String title) {
    if (mounted) {
      setState(() {
        final markerId = MarkerId(point.toString());
        _markers.add(
          Marker(
            markerId: MarkerId(point.toString()),
            position: point,
            infoWindow: InfoWindow(title: title),
            onTap: () => _onMarkerTapped(markerId), // Add this line
          ),
        );
      });
    }
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polygon_$_polylineIdCounter';
    _polylineIdCounter++;
    _polyline.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permently denied, we cannot request');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vet Clinics')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Text(
                    //   locationMessage,
                    //   textAlign: TextAlign.center,
                    // ),
                    TextFormField(
                      controller: _originController,
                      decoration: InputDecoration(hintText: 'Origin'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(hintText: 'Destination'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  _goToPlace(
                    directions['start_location']['lat'],
                    directions['end_location']['lng'],
                    directions['bounds_ne'],
                    directions['bounds_sw'],
                  );

                  _setPolyline(directions['polyline_decoded']);
                },
                icon: Icon(Icons.search),
              ),
              ElevatedButton(
                onPressed: () {
                  _getSingleVetClinicDetailsFireBase(selectedMarkerLat,
                      selectedMarkerLng); // Pass the lat and long from your current location
                },
                child: Text("Add Bookmark"),
              )
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              // polygons: _polygons,
              polylines: _polyline,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _handleMapTap,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic>? boundsNe,
    Map<String, dynamic>? boundsSw,
  ) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 12,
        ),
      ),
    );

    if (boundsNe != null && boundsSw != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25,
        ),
      );
    }

    _setMarker(
      LatLng(lat, lng),
      "",
    );
  }

  void _updateDestination(LatLng point) {
    if (mounted) {
      setState(() {
        _destinationController.text = '${point.latitude}, ${point.longitude}';
        _updatePolylines(
            point); // Update polylines based on the new destination
      });
    }
  }

  void _updatePolylines(LatLng destination) async {
    var directions = await LocationService().getDirections(
      _originController.text,
      '${destination.latitude}, ${destination.longitude}',
    );

    if (mounted) {
      setState(() {
        _polyline.clear(); // Clear existing polylines
        _setPolyline(directions['polyline_decoded']); // Set new polylines
      });
    }
  }

  void _getVetClinics() async {
    print("Fetching vet clinics..."); // Add this line for debugging
    Position position = await _getCurrentLocation();
    LatLng origin = LatLng(position.latitude, position.longitude);
    var results = await LocationService().fetchNearbyPetClinics(origin);
    print("Results: $results"); // Add this line for debugging
    if (results != null) {
      for (var result in results) {
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final petStoreLocation = LatLng(lat, lng);
        final name = result['name']; // Get the name of the place

        // Add a marker for each pet store
        _setMarker(petStoreLocation, name);
      }
    } else {
      print("No vet clinics found or an error occurred.");
    }
  }

  void _getSingleVetClinicDetails(double lat, double lng) async {
    Position position = await _getCurrentLocation();
    LatLng origin = LatLng(position.latitude, position.longitude);
    var results = await LocationService().fetchNearbyPetClinics(origin);

    for (var result in results) {
      final storeLat = result['geometry']['location']['lat'];
      final storeLng = result['geometry']['location']['lng'];
      final placeId = result['place_id']; // Get the Place ID

      if (storeLat == lat && storeLng == lng) {
        // Fetch contact number and website using Place Details API
        final placeDetails = await LocationService().fetchPlaceDetails(placeId);
        var contactNumber = placeDetails['formatted_phone_number'];
        var website = placeDetails['website'];

        final name = result['name'];
        final address = result['vicinity'];

        if (contactNumber == null) {
          contactNumber = "none";
        } else {
          website ??= "none";
        }
        print("Name: $name");
        print("Address: $address");
        print("Contact Number: $contactNumber");
        print("Website: $website");

        LatLng newDest = LatLng(storeLat, storeLng);
        _updateDestination(newDest);
      }
    }
  }

  void _getSingleVetClinicDetailsFireBase(double lat, double lng) async {
    Position position = await _getCurrentLocation();
    LatLng origin = LatLng(position.latitude, position.longitude);
    var results = await LocationService().fetchNearbyPetClinics(origin);

    for (var result in results) {
      final storeLat = result['geometry']['location']['lat'];
      final storeLng = result['geometry']['location']['lng'];
      final placeId = result['place_id']; // Get the Place ID

      if (storeLat == lat && storeLng == lng) {
        // Fetch contact number and website using Place Details API
        final placeDetails = await LocationService().fetchPlaceDetails(placeId);
        var contactNumber = placeDetails['formatted_phone_number'];
        var website = placeDetails['website'];

        final name = result['name'];
        final address = result['vicinity'];

        if (contactNumber == null) {
          contactNumber = "none";
        } else {
          website ??= "none";
        }
        print("Name: $name");
        print("Address: $address");
        print("Contact Number: $contactNumber");
        print("Website: $website");

        try {
          Response res = await FirebaseCrudVetClinic.addVetClinic(
              name, address, contactNumber, website, storeLat, storeLng);
          print('Bookmark added to Firebase');
          Fluttertoast.showToast(
            msg: 'Bookmark added',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } catch (e) {
          print('Error adding bookmark to Firebase: $e');
          Fluttertoast.showToast(
            msg: 'Error adding bookmark',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    }
  }

  final Marker nullMarker = Marker(
    markerId: MarkerId('null_marker'),
    position: LatLng(0, 0), // You can use any coordinates here
  );

  void _onMarkerTapped(MarkerId markerId) {
    // Find the selected pet store marker by its ID
    Marker selectedMarker = _markers.firstWhere(
      (marker) => marker.markerId == markerId,
      orElse: () => nullMarker,
    );

    if (selectedMarker != nullMarker) {
      // Get the latitude and longitude of the selected marker
      selectedMarkerLat = selectedMarker.position.latitude;
      selectedMarkerLng = selectedMarker.position.longitude;

      // Fetch details of the selected pet store using its coordinates
      _getSingleVetClinicDetails(selectedMarkerLat, selectedMarkerLng);
    }
  }

  void _handleMapTap(LatLng point) {
    if (mounted) {
      setState(() {
        _destinationController.text = '${point.latitude}, ${point.longitude}';
        _updatePolylines(
            point); // Update polylines based on the new destination
        polygonLatLngs.add(point);
        _setPolygon();
        _updateDestination(point);
      });
    }
  }
}

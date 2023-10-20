// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_uee/pages/pet_services/location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PetShopSearchPage extends StatefulWidget {
  const PetShopSearchPage({super.key});

  @override
  State<PetShopSearchPage> createState() => PetShopSearchPageState();
}

class PetShopSearchPageState extends State<PetShopSearchPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  TextEditingController _originController = TextEditingController();

  TextEditingController _destinationController = TextEditingController();

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
    _getCurrentLocation().then((value) {
      lat = '${value.latitude}';
      long = '${value.longitude}';
      setState(() {
        locationMessage = 'Latitude: $lat, Longitude: $long';
        // Set the current location to the _originController
        _originController.text = '$lat, $long';
        _setMarker(LatLng(value.latitude, value.longitude));
      });
    });
    // _setMarker(
    //   LatLng(37.42796133580664, -122.085749655962),
    // );
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(point.toString()),
          position: point,
        ),
      );
    });
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
      appBar: AppBar(title: Text('Google Maps')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locationMessage,
                      textAlign: TextAlign.center,
                    ),
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
                  _getPetStores();
                },
                child: const Text("Get Current Location"),
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
              // onTap: (point) {
              //   setState(() {
              //     polygonLatLngs.add(point);
              //     _setPolygon();
              //     _updateDestination(
              //         point); // Update destination when the map is tapped
              //   });
              // },
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
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
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
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    _setMarker(
      LatLng(lat, lng),
    );
  }

  void _updateDestination(LatLng point) {
    setState(() {
      _destinationController.text = '${point.latitude}, ${point.longitude}';
      _updatePolylines(point); // Update polylines based on the new destination
    });
  }

  void _updatePolylines(LatLng destination) async {
    var directions = await LocationService().getDirections(
      _originController.text,
      '${destination.latitude}, ${destination.longitude}',
    );

    setState(() {
      _polyline.clear(); // Clear existing polylines
      _setPolyline(directions['polyline_decoded']); // Set new polylines
    });
  }

  void _getPetStores() async {
    print("Fetching pet stores..."); // Add this line for debugging
    Position position = await _getCurrentLocation();
    LatLng origin = LatLng(position.latitude, position.longitude);
    var results = await LocationService().fetchNearbyPetStores(origin);
    print("Results: $results"); // Add this line for debugging
    if (results != null) {
      for (var result in results) {
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final petStoreLocation = LatLng(lat, lng);
        // Add a marker for each pet store
        _setMarker(petStoreLocation);
      }
    } else {
      print("No pet stores found or an error occurred.");
    }
  }

  void _handleMapTap(LatLng point) {
    setState(() {
      _destinationController.text = '${point.latitude}, ${point.longitude}';
      // _updatePolylines(point); // Update polylines based on the new destination
      polygonLatLngs.add(point);
      _setPolygon();
      _updateDestination(point);
    });
  }
}

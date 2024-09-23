import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/customer/loading.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:http/http.dart' as http;

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final UserDatabaseServices _databaseServices = UserDatabaseServices();
  final Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  bool markerPlaced = false;
  bool mapLoaded = false;
  BitmapDescriptor? myLocationIcon;
  StreamSubscription<LocationData>? _locationSubscription;
  final searchController = TextEditingController();
  List<dynamic> listOfLocations = [];
  final String token = '1234567890';

  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    getLocationUpdates();
    _userDataFuture = getUserData();
  }

  @override
  void dispose() {
    // Cancel the location subscription to avoid memory leaks
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCustomMarker() async {
    final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(200, 200)),
      'assets/images/location-pin.png',
    );
    setState(() {
      myLocationIcon = markerIcon;
    });
  }

  void getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        source = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        if (mounted) {
          setState(() {
            if (!markerPlaced) {
              currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
              source = LatLng(currentLocation.latitude!, currentLocation.longitude!);
              markerPlaced = true;
              mapLoaded = true; // Set mapLoaded to true when currentP is set
            }
          });
        }
      }
    });
  }

  // Future<LatLng> getLocation() async {
  //   bool _serviceEnabled = await _locationController.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await _locationController.requestService();
  //     if (!_serviceEnabled) {
  //       throw Exception("Location service not enabled");
  //     }
  //   }
  //
  //   PermissionStatus _permissionGranted = await _locationController.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await _locationController.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       throw Exception("Location permission not granted");
  //     }
  //   }
  //
  //   LocationData locationData = await _locationController.getLocation();
  //   if (locationData.latitude == null || locationData.longitude == null) {
  //     throw Exception("Failed to get location");
  //   }
  //   return LatLng(locationData.latitude!, locationData.longitude!);
  // }
  //
  Future<Map<String, dynamic>> getUserData() async {
    DocumentSnapshot userDoc = await _databaseServices.getCurrentUserDoc();
    return userDoc.data() as Map<String, dynamic>;
  }

  String locationString(LatLng pos) {
    String latitude = pos.latitude.toStringAsFixed(6);
    String longitude = pos.longitude.toStringAsFixed(6);
    return "($latitude , $longitude)";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting || !markerPlaced) {
          return const Loading();
        } else if (userSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${userSnapshot.error}'),
            ),
          );
        } else {
          return buildMap(userSnapshot.data!);
        }
      },
    );
  }

  Widget buildMap(Map<String, dynamic> userData) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            initialCameraPosition: CameraPosition(
              target: currentP!,
              zoom: 18,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            onCameraMove: (CameraPosition position) {
              currentP = LatLng(position.target.latitude, position.target.longitude);
              setState(() {
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: const MarkerId('marker_id'),
                    position: currentP!,
                    icon: myLocationIcon!,
                  ),
                );
              });
            },
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14.0, 40.0, 14.0, 15.0),
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome ${userData['Name']}",
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Text(
                      "Set location on map",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    if (currentP != null) Text(locationString(currentP!)),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print(currentP);
                            Navigator.pushNamed(context, '/search', arguments: {'location': currentP});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0CAC8F),
                            padding: const EdgeInsets.fromLTRB(54.0, 13.0, 54.0, 11.0),
                          ),
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentP != null && _controller != null) {
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: source!,
                  zoom: 18,
                ),
              ),
            );
          }
        },
        child: const Icon(
          Icons.my_location_outlined,
        ),
      ),
    );
  }
}


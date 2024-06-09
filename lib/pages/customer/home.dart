import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/customer/loading.dart';
import 'package:medifinder/services/database_services.dart';


class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key}) : super(key: key);

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final UserDatabaseServices _databaseServices = UserDatabaseServices();
  Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool markerPlaced = false;

  late Future<LatLng> _locationFuture;
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = getLocation();
    _userDataFuture = getUserData();
  }

  Future<LatLng> getLocation() async {
    bool _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        throw Exception("Location service not enabled");
      }
    }

    PermissionStatus _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception("Location permission not granted");
      }
    }

    LocationData locationData = await _locationController.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) {
      throw Exception("Failed to get location");
    }

    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  Future<Map<String, dynamic>> getUserData() async {
    DocumentSnapshot userDoc = await _databaseServices.getCurrentUserDoc();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: _locationFuture,
      builder: (context, locationSnapshot) {
        if (locationSnapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (locationSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${locationSnapshot.error}'),
            ),
          );
        } else {
          currentP = locationSnapshot.data!;
          source = currentP;
          // _markers.add(
          //   Marker(
          //     markerId: MarkerId('1'),
          //     position: currentP!,
          //   ),
          // );
          return FutureBuilder<Map<String, dynamic>>(
            future: _userDataFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
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
            onCameraMove: (CameraPosition _position) {
              currentP = LatLng(_position.target.latitude, _position.target.longitude);
              setState(() {
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId('marker_id'),
                    position: currentP!,
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
                padding: EdgeInsets.fromLTRB(14.0, 40.0, 14.0, 15.0),
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
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      "Set location on map",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    if (currentP != null) Text(locationString(currentP!)),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/search', arguments: {'location': currentP});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF12E7C0),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Activities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: 0,
        onTap: (int n) {
          if (n == 1) Navigator.pushNamed(context, '/activities');
          if (n == 2) Navigator.pushNamed(context, '/profile');
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}

String locationString(LatLng pos) {
  String latitude = pos.latitude.toStringAsFixed(6);
  String longitude = pos.longitude.toStringAsFixed(6);
  return "($latitude , $longitude)";
}
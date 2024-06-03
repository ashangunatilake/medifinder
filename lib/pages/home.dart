import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/loading.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final UserDatabaseServices _databaseServices = UserDatabaseServices();
  late SharedPreferences sharedPreferences;
  late String? uid;
  late UserModel? userModel;
  Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool markerPlaced = false;
  bool mapLoaded = false; // To track whether map is loaded

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    initGetSavedUserData();
  }

  void initGetSavedUserData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    uid = await _databaseServices.getCurrentUserUid();
    Map<String, dynamic> jsonUserdata = jsonDecode(sharedPreferences.getString('userdata')!);
    userModel = UserModel.fromJson(uid!, jsonUserdata);
  }

  @override
  Widget build(BuildContext context) {
    return currentP == null ? const Loading() : buildMap();
  }

  Widget buildMap() {
    _markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: currentP!,
      ),
    );
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
            onCameraMove: (CameraPosition _position){
              currentP = LatLng(_position.target.latitude, _position.target.longitude);
              setState(() {
                _markers.clear();
                _markers.add(
                    Marker(
                        markerId: MarkerId('marker_id'),
                        position: currentP!
                    )
                );
              });
            } ,
            // onTap: (LatLng latLng) {
            //   setState(() {
            //     currentP = latLng;
            //     _markers.clear();
            //     _markers.add(
            //       Marker(
            //         markerId: MarkerId('marker_id'),
            //         position: latLng,
            //         draggable: true,
            //         onDragEnd: (LatLng newP) {
            //           setState(() {
            //             currentP = newP;
            //           });
            //         },
            //       ),
            //     );
            //   });
            // },
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
                      "Welcome ${userModel!.name}",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Set location on map",
                        style: TextStyle(
                          fontSize: 12.0,
                        )),
                    SizedBox(
                      height: 5.0,
                    ),
                    if (currentP != null)
                      Text(locationString(currentP!)),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/search', arguments: {'user': userModel, 'location': currentP});
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12E7C0),
                              padding: const EdgeInsets.fromLTRB(
                                  54.0, 13.0, 54.0, 11.0)),
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
              label: "Profile"
          )
        ],
        currentIndex: 0,
        onTap: (int n) {
          if (n == 1) Navigator.pushNamed(context, '/activities');
          if (n == 2) Navigator.pushNamed(context, '/profile', arguments: userModel);
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }

  void getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        source = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        setState(() {
          if (!markerPlaced) {
            currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            source = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            markerPlaced = true;
            mapLoaded = true; // Set mapLoaded to true when currentP is set
          }
        });
      }
    });
  }
}

String locationString(LatLng pos) {
  String latitude = pos.latitude.toStringAsFixed(6);
  String longitude = pos.longitude.toStringAsFixed(6);
  return "($latitude , $longitude)";
}



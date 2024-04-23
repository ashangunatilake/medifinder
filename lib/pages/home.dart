import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/loading.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  String user = "Ashan";
  bool markerPlaced = false;
  bool mapLoaded = false; // To track whether map is loaded

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return currentP == null ? const Loading() : buildMap();
  }

  Widget buildMap() {
    _markers.add(
      Marker(
        markerId: MarkerId('current_location'),
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
            markers: _markers,
            onTap: (LatLng latLng) {
              setState(() {
                currentP = latLng;
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId('marker_id'),
                    position: latLng,
                    draggable: true,
                    onDragEnd: (LatLng newP) {
                      setState(() {
                        currentP = newP;
                      });
                    },
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
                      "Welcome $user",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Select location by tapping on the map",
                        style: TextStyle(
                          fontSize: 10.0,
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
                          onPressed: () {},
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
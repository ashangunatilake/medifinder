import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/customer/loading.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _controller;
  final Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  final Set<Marker> _markers = {};
  bool markerPlaced = false;
  bool mapLoaded = false; // To track whether map is loaded
  BitmapDescriptor? myLocationIcon;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    getLocationUpdates();
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
    if (mounted) {
      setState(() {
        myLocationIcon = markerIcon;
      });
    }
  }

  String locationString(LatLng pos) {
    String latitude = pos.latitude.toStringAsFixed(6);
    String longitude = pos.longitude.toStringAsFixed(6);
    return "($latitude , $longitude)";
  }

  @override
  Widget build(BuildContext context) {
    return currentP == null ? const Loading() : buildMap();
  }

  Widget buildMap() {
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
              if (mounted) {
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
              }
            },
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafeArea(
                  child: SizedBox(
                    height: 5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14.0, 20.0, 14.0, 15.0),
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              if (currentP != null) {
                                Navigator.pop(context, currentP);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a location')),
                                );
                              }
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
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
}




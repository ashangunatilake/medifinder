import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:medifinder/pages/customer/loading.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _controller;
  Location _locationController = Location();
  LatLng? currentP;
  LatLng? source;
  Set<Marker> _markers = {};
  bool markerPlaced = false;
  bool mapLoaded = false; // To track whether map is loaded
  BitmapDescriptor? myLocationIcon;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    getLocationUpdates();
  }

  Future<void> loadCustomMarker() async {
    final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(200, 200)),
      'assets/location-pin.png',
    );
    setState(() {
      myLocationIcon = markerIcon;
    });
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
            onCameraMove: (CameraPosition _position){
              currentP = LatLng(_position.target.latitude, _position.target.longitude);
              setState(() {
                _markers.clear();
                _markers.add(
                    Marker(
                        markerId: MarkerId('marker_id'),
                        position: currentP!,
                        icon: myLocationIcon!
                    )
                );
              });
            } ,
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
                    )
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(14.0, 20.0, 14.0, 15.0),
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              if (currentP != null) {
                                Navigator.pop(context, currentP);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please select a location')),
                                );
                              }
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
              ],
            )
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
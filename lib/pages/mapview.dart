import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapView extends StatefulWidget {
  MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng location;
  late List<DocumentSnapshot> pharmacies;
  bool loaded = false;
  BitmapDescriptor? myLocationIcon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      location = args['location'] as LatLng;
      pharmacies = args['pharmacies'] as List<DocumentSnapshot>;
      print(location);
    } else {
      // Handle the case where args are null (optional)
      // You might want to throw an error or use default values
      location = LatLng(0.0, 0.0); // Default location
      pharmacies = [];
      print('No arguments passed');
    }
    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
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

  @override
  Widget build(BuildContext context) {
    return (loaded) ? Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: location,
              zoom: 14
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId('user_location'),
                position: location,
                infoWindow: InfoWindow(
                  title: 'My Location',
                ),
                icon: myLocationIcon!,
              ),
              ...pharmacies.map((pharmacy) {
                GeoPoint geoPoint = pharmacy['Position']['geopoint'] as GeoPoint;
                return Marker(
                  markerId: MarkerId(pharmacy.id),
                  position: LatLng(geoPoint.latitude, geoPoint.longitude),
                  infoWindow: InfoWindow(
                    title: pharmacy['Name'] ?? 'Pharmacy',
                  ),
                );
              }).toSet(),
            },
          )
        ],
      ),
    ) :  CircularProgressIndicator();
  }
}


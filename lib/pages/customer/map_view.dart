import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final LatLng userLocation;
  final List<Map<String, dynamic>> pharmacyLocations;

  const MapView({
    required this.userLocation,
    required this.pharmacyLocations,
  });

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId('userLocation'),
        position: userLocation,
        infoWindow: InfoWindow(title: 'Your Location'),
      ),
    };

    for (var pharmacy in pharmacyLocations) {
      markers.add(
        Marker(
          markerId: MarkerId(pharmacy['id']),
          position: pharmacy['location'],
          infoWindow: InfoWindow(title: pharmacy['name']),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: userLocation,
          zoom: 12,
        ),
        markers: markers,
      ),
    );
  }
}

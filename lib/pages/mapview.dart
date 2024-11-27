import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng location;
  late List<Map<String, dynamic>> pharmacies;
  bool loaded = false;
  BitmapDescriptor? myLocationIcon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      location = args['location'] as LatLng;
      Set<Map<String, dynamic>> uniquePharmacies = {};
      for (var pharmacy in args['pharmacies']) {
        Map<String, dynamic> data= {'id': pharmacy['pharmacy'].id};
        data.addAll(pharmacy['pharmacy'].data() as Map<String, dynamic>);
        uniquePharmacies.add(data);
      }
      pharmacies = uniquePharmacies.toList() ;
    } else {
      location = const LatLng(0.0, 0.0); // Default location
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
      const ImageConfiguration(size: Size(200, 200)),
      'assets/images/location-pin.png',
    );
    setState(() {
      myLocationIcon = markerIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (loaded) ? Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Map view"),
        backgroundColor: const Color(0xFF399479),
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 14
        ),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        markers: {
          Marker(
            markerId: const MarkerId('user_location'),
            position: location,
            infoWindow: const InfoWindow(
              title: 'My Location',
            ),
            icon: myLocationIcon!,
          ),
          ...pharmacies.map((pharmacy) {
            GeoPoint geoPoint = pharmacy['Position']['geopoint'] as GeoPoint;
            return Marker(
              markerId: MarkerId(pharmacy['id']),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(
                title: pharmacy['Name'] ?? 'Pharmacy',
              ),
            );
          }).toSet(),
        },
      ),
    ) :  const CircularProgressIndicator();
  }
}


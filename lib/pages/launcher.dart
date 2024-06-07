import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  static Future<void> openMap(GeoPoint geoPoint) async {
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    print('URL: $googleUrl');
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }
  static Future<void> openDialler(String phoneNumber) async {
    Uri uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(" ", ""));
    await launchUrl(uri);
  }
}
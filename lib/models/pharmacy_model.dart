import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

final geo = GeoFlutterFire();

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final String contact;
  final double ratings;
  final bool isDeliveryAvailable;
  final String operationHours;
  final GeoFirePoint position;

  const PharmacyModel ({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.ratings,
    required this.isDeliveryAvailable,
    required this.operationHours,
    required this.position,
  });

  static PharmacyModel empty() => PharmacyModel(id: '', name: '', address: '', contact: '', ratings: 0, isDeliveryAvailable: false, operationHours: '', position: geo.point(latitude: 0, longitude: 0));

  factory PharmacyModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return PharmacyModel(
        id: document.id,
        name: data['Name'] as String? ?? '',
        address: data['Address'] as String? ?? '',
        contact: data['ContactNo'] as String? ?? '',
        ratings: data['Ratings'] as double? ?? 0,
        isDeliveryAvailable: data['DeliveryServiceAvailability'] as bool? ?? false,
        operationHours: data['HoursOfOperation'] as String? ?? '',
        position: geo.point(
          latitude: (data['Position']['geopoint'] as GeoPoint).latitude,
          longitude: (data['Position']['geopoint'] as GeoPoint).longitude,
        ),
      );
    }
    else {
      return PharmacyModel.empty();
    }
  }

  // create a new instance of UserModel with modified/updated properties
  PharmacyModel copyWith({
    String? name,
    String? address,
    String? contact,
    double? ratings,
    bool? isDeliveryAvailable,
    String? operationHours,
    GeoFirePoint? position,
  }) {
    return PharmacyModel(id: this.id, name: name ?? this.name, address: address ?? this.address, contact: contact ?? this.contact, ratings: ratings ?? this.ratings, isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable, operationHours: operationHours ?? this.operationHours, position: position ?? this.position,);
  }

  // create a json object of a UserModel instance
  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Address': address,
      'ContactNo': contact,
      'Ratings': ratings,
      'DeliveryServiceAvailability': isDeliveryAvailable,
      'HoursOfOperation': operationHours,
      'Position': {
        'geopoint': GeoPoint(position.latitude, position.longitude),
        'geohash': position.hash,
      },
    };
  }
}



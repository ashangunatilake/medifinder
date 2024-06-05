import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final String contact;
  final double ratings;
  final bool isDeliveryAvailable;
  final String operationHours;
  final GeoPoint location;

  const PharmacyModel ({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.ratings,
    required this.isDeliveryAvailable,
    required this.operationHours,
    required this.location,
  });

  static PharmacyModel empty() => const PharmacyModel(id: '', name: '', address: '', contact: '', ratings: 0, isDeliveryAvailable: false, operationHours: '', location: GeoPoint(0.0, 0.0));

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
        location: data['Location'] as GeoPoint? ?? GeoPoint(0.0, 0.0),
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
    GeoPoint? location,
  }) {
    return PharmacyModel(id: this.id, name: name ?? this.name, address: address ?? this.address, contact: contact ?? this.contact, ratings: ratings ?? this.ratings, isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable, operationHours: operationHours ?? this.operationHours, location: location ?? this.location,);
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
      'Location': location,
    };
  }
}



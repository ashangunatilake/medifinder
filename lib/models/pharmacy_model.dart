import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/models/user_review_model.dart';
import 'package:geolocator/geolocator.dart';

class PharmacyModel {
  final String name;
  final String address;
  final String contact;
  final double ratings;
  final bool isDeliveryAvailable;
  final String operationHours;
  final GeoPoint location;
  // final List<UserOrder>? orders;
  // final List<UserReview>? reviews;

  const PharmacyModel ({
    required this.name,
    required this.address,
    required this.contact,
    required this.ratings,
    required this.isDeliveryAvailable,
    required this.operationHours,
    required this.location,
  });

  // create a PharmacyModel instance using a json object
  factory PharmacyModel.fromJson(Map<String, Object?> json) {
    // final List<UserOrder> orders = (json['Orders'] as List<dynamic>?)
    //     ?.map((orderJson) => UserOrder.fromJson(orderJson))
    //     .toList() ?? [];
    // final List<UserReview> reviews = (json['Reviews'] as List<dynamic>?)
    //     ?.map((reviewJson) => UserReview.fromJson(reviewJson))
    //     .toList() ?? [];

    return PharmacyModel(
      name: json['Name']! as String,
      address: json['Address']! as String,
      contact: json['ContactNo']! as String,
      ratings: json['Ratings']! as double,
      isDeliveryAvailable: json['DeliveryServiceAvailability']! as bool,
      operationHours: json['HoursOfOperation']! as String,
      location: json['Location']! as GeoPoint,
      // orders: orders,
      // reviews: reviews,
    );
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
    // List<UserOrder>? orders,
    // List<UserReview>? reviews,
  }) {
    return PharmacyModel(name: name ?? this.name, address: address ?? this.address, contact: contact ?? this.contact, ratings: ratings ?? this.ratings, isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable, operationHours: operationHours ?? this.operationHours, location: location ?? this.location,);
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
      // 'Orders': orders?.map((order) => order.toJson()).toList(),
      // 'Reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrder {
  final String id;
  final String did;
  final String drugName;
  final String pid;
  final String url;
  final int quantity;
  final bool delivery;
  final bool isAccepted;
  final bool isCompleted;
  final GeoPoint? location;

  const UserOrder({
    required this.id,
    required this.did,
    required this.drugName,
    required this.pid,
    required this.url,
    required this.quantity,
    required this.delivery,
    required this.isAccepted,
    required this.isCompleted,
    this.location,
  });

  static UserOrder empty() => const UserOrder(
    id: '',
    did: '',
    drugName: '',
    pid: '',
    url: '',
    quantity: 0,
    delivery: false,
    isAccepted: false,
    isCompleted: false,
    location: null,
  );

  factory UserOrder.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return UserOrder(
        id: document.id,
        did: data['DrugID'] ?? '',
        drugName: data['DrugName'],
        pid: data['PharmacyID'] ?? '',
        url: data['PrescriptionURL'] ?? '',
        quantity: (data['Quantity'] is int) ? data['Quantity'] as int : 0,
        delivery: data['DeliveryMethod'] ?? false,
        isAccepted: data['Accepted'] ?? false,
        isCompleted: data['Completed'] ?? false,
        location: data['UserLocation'],
      );
    } else {
      return UserOrder.empty();
    }
  }

  UserOrder.fromJson(String userID, Map<String, Object?> json)
      : this(
    id: userID,
    did: json['DrugID'] as String,
    drugName: json['DrugName'] as String,
    pid: json['PharmacyID'] as String,
    url: json['PrescriptionURL'] as String,
    quantity: json['Quantity'] as int,
    delivery: json['DeliveryMethod'] as bool,
    isAccepted: json['Accepted'] as bool,
    isCompleted: json['Completed'] as bool,
    location: json['UserLocation'] as GeoPoint?,
  );

  UserOrder copyWith({
    String? did,
    String? drugName,
    String? pid,
    String? url,
    int? quantity,
    bool? delivery,
    bool? isAccepted,
    bool? isCompleted,
    GeoPoint? location,
  }) {
    return UserOrder(
      id: id,
      did: did ?? this.did,
      drugName: drugName ?? this.drugName,
      pid: pid ?? this.pid,
      url: url ?? this.url,
      quantity: quantity ?? this.quantity,
      delivery: delivery ?? this.delivery,
      isAccepted: isAccepted ?? this.isAccepted,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'DrugID': did,
      'DrugName': drugName,
      'PharmacyID': pid,
      'PrescriptionURL': url,
      'Quantity': quantity,
      'DeliveryMethod': delivery,
      'Accepted': isAccepted,
      'Completed': isCompleted,
      'UserLocation': location,
    };
  }
}

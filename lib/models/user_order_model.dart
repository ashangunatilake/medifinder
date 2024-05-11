import 'package:firebase_auth/firebase_auth.dart';

class UserOrder {
  final String did;
  final String pid;
  final String url;
  final double quantity;

  const UserOrder({
    required this.did,
    required this.pid,
    required this.url,
    required this.quantity,
  });

  UserOrder.fromJson(Map<String, Object?> json)
    :this(
      did: json['DrugID']! as String,
      pid: json['PharmacyID']! as String,
      url: json['PrescriptionURL']! as String,
      quantity: json['Quantity']! as double,
    );

  UserOrder copyWith({
    String? did,
    String? pid,
    String? url,
    double? quantity,

  }) {
    return UserOrder(did: did ?? this.did, pid: pid ?? this.pid, url: url ?? this.url, quantity: quantity ?? this.quantity);
  }

  Map<String, Object?> toJson() {
    return {
      'DrugID': did,
      'PharmacyID': pid,
      'PrescriptionURL': url,
      'Quantity': quantity,
    };
  }
}
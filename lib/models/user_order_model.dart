import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrder {
  final String id;
  final String did;
  final String url;
  final double quantity;
  final bool delivery;
  final bool isAccepted;
  final bool isCompleted;


  const UserOrder({
    required this.id,
    required this.did,
    required this.url,
    required this.quantity,
    required this.delivery,
    required this.isAccepted,
    required this.isCompleted,
  });

  static UserOrder empty() => const UserOrder(id: '', did: '', url: '', quantity: 0, delivery: false, isAccepted: false, isCompleted: false);

  factory UserOrder.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return UserOrder(
        id: document.id,
        did: data['DrugID'] ?? '',
        url: data['PrescriptionURL'] ?? '',
        quantity: data['Quantity'] ?? 0,
        delivery: data['DeliveryMethod'] ?? false,
        isAccepted: data['Accepted'] ?? false,
        isCompleted: data['Completed'] ?? false,
      );
    }
    else {
      return UserOrder.empty();
    }
  }

  UserOrder.fromJson(String userID, Map<String, Object?> json)
    :this(
      id: userID,
      did: json['DrugID']! as String,
      url: json['PrescriptionURL']! as String,
      quantity: json['Quantity']! as double,
      delivery: json['DeliveryMethod'] as bool,
      isAccepted: json['Accepted'] as bool,
      isCompleted: json['Completed'] as bool,
    );

  UserOrder copyWith({
    String? did,
    String? url,
    double? quantity,
    bool? delivery,
    bool? isAccepted,
    bool? isCompleted,
  }) {
    return UserOrder(id: this.id, did: did ?? this.did, url: url ?? this.url, quantity: quantity ?? this.quantity, delivery: delivery ?? this.delivery, isAccepted: isAccepted ?? this.isAccepted, isCompleted: isCompleted ?? this.isCompleted);
  }

  Map<String, Object?> toJson() {
    return {
      'DrugID': did,
      'PrescriptionURL': url,
      'Quantity': quantity,
      'DeliveryMethod': delivery,
      'Accepted': isAccepted,
      'Completed':isCompleted,
    };
  }
}
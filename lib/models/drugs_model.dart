import 'package:cloud_firestore/cloud_firestore.dart';

class DrugsModel {
  final String brand;
  final String name;
  final String dosage;
  final int quantity;
  final double price;

  const DrugsModel({
    required this.brand,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.price,
  });

  static DrugsModel empty() => const DrugsModel(
    brand: '',
    name: '',
    dosage: '',
    quantity: 0,
    price: 0.0,
  );

  factory DrugsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return DrugsModel(
        brand: data['BrandName'] ?? '',
        name: data['Name'] ?? '',
        dosage: data['Dosage'] ?? '',
        quantity: (data['Quantity'] is int) ? data['Quantity'] as int : 0,
        price: (data['UnitPrice'] is double) ? data['UnitPrice'] as double : (data['UnitPrice'] is int) ? (data['UnitPrice'] as int).toDouble() : 0.0,
      );
    } else {
      return DrugsModel.empty();
    }
  }

  DrugsModel copyWith({
    String? brand,
    String? name,
    String? dosage,
    int? quantity,
    double? price,
  }) {
    return DrugsModel(brand: brand ?? this.brand, name: name ?? this.name, dosage: dosage ?? this.dosage, quantity: quantity ?? this.quantity, price: price ?? this.price);
  }

  Map<String, Object?> toJson() {
    return {
      'BrandName': brand,
      'Name': name,
      'Dosage': dosage,
      'Quantity': quantity,
      'UnitPrice': price,
    };
  }
}

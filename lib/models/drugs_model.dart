import 'package:cloud_firestore/cloud_firestore.dart';

class DrugsModel {
  final String brand;
  final String name;
  final String dosage;
  final double quantity;
  final double price;

  const DrugsModel({
    required this.brand,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.price,
  });

  static DrugsModel empty() => const DrugsModel(brand: '', name: '', dosage: '', quantity: 0, price: 0);

  factory DrugsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return DrugsModel(
        brand: data['BrandName'] ?? '',
        name: data['Name'] ?? '',
        dosage: data['Dosage'] ?? '',
        quantity: data['Quantity'] ?? 0,
        price: data['UnitPrice'] ?? 0,
      );
    }
    else {
      return DrugsModel.empty();
    }
  }
  // DrugsModel.fromJson(Map<String, Object?> json)
  //     :this(
  //   brand: json['BrandName']! as String,
  //   name: json['Name']! as String,
  //   dosage: json['Dosage']! as String,
  //   quantity: json['Quantity']! as double,
  //   price: json['UnitPrice']! as double,
  // );

  DrugsModel copyWith({
    String? brand,
    String? name,
    String? dosage,
    double? quantity,
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
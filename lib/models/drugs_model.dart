

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

  DrugsModel.fromJson(Map<String, Object?> json)
      :this(
    brand: json['BrandName']! as String,
    name: json['Name']! as String,
    dosage: json['Dosage']! as String,
    quantity: json['Quantity']! as double,
    price: json['UnitPrice']! as double,
  );

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
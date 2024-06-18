// lib/models/drug_model.dart
class DrugModel {
  final String id; // Add id field
  final String name;
  final String brand;
  final String dosage;
  final String price;
  final String quantity;

  DrugModel({
    required this.id, // Update constructor to include id
    required this.name,
    required this.brand,
    required this.dosage,
    required this.price,
    required this.quantity,
  });

  // Factory method to create DrugModel from Firestore document
  factory DrugModel.fromMap(String id, Map<String, dynamic> map) {
    return DrugModel(
      id: id,
      name: map['name'],
      brand: map['brand'],
      dosage: map['dosage'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  // Method to convert DrugModel to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'dosage': dosage,
      'price': price,
      'quantity': quantity,
    };
  }
}

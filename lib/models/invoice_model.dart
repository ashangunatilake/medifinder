import 'package:medifinder/models/pharmacy_model.dart';
import 'package:medifinder/models/user_model.dart';

class Invoice {
  final InvoiceInfo info;
  final PharmacyModel pharmacy;
  final UserModel customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.pharmacy,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
  });
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.unitPrice,
  });
}
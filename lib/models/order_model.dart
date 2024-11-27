class OrderItem {
  final String itemName;
  final int quantity;
  final double price;

  OrderItem(
      {required this.itemName, required this.quantity, required this.price});

  // Factory constructor to create an instance from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemName: json['itemName'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String customerName;
  final List<OrderItem> items;

  Order({required this.customerName, required this.items});

  // Factory constructor to create an instance from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<OrderItem> itemList =
        itemsFromJson.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      customerName: json['customerName'],
      items: itemList,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

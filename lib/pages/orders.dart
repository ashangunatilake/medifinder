import 'package:flutter/material.dart';
import 'package:medifinder/models/order_model.dart';
import 'orderDetails.dart';

class Orders extends StatelessWidget {
  final List<Order> orders = [
    Order(
      customerName: 'Customer 1',
      items: [
        OrderItem(itemName: 'Medicine A', quantity: 2, price: 20.0),
      ],
      prescriptionUrl:
          'https://c.ndtvimg.com/2022-09/2tcj87po_doctor-neat-prescription-650_625x300_28_September_22.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    Order(
      customerName: 'Customer 2',
      items: [
        OrderItem(itemName: 'Medicine C', quantity: 3, price: 30.0),
      ],
      prescriptionUrl: 'https://example.com/prescription1.jpg',
    ),
    // Add more orders as needed
  ];

  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetails(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => _navigateToOrderDetails(context, orders[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      orders[index].customerName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medifinder/models/user_order_model.dart';

class OrderDetails extends StatelessWidget {
  final UserOrder order;

  OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Drug ID: ${order.did}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Pharmacy ID: ${order.pid}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Quantity: ${order.quantity}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Delivery Method: ${order.delivery ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Accepted: ${order.isAccepted ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Completed: ${order.isCompleted ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Image.network(order.url),
          ],
        ),
      ),
    );
  }
}

// // lib/pages/order_details_page.dart

// import 'package:flutter/material.dart';
// import 'package:medifinder/models/order_model.dart';

// class OrderDetails extends StatelessWidget {
//   final Order order;

//   OrderDetails({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             '${order.customerName}\'s Order'), // Correctly displaying the customer name
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage('assets/images/add_bg.png'),
//                   fit: BoxFit.cover),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView.builder(
//               itemCount: order.items.length,
//               itemBuilder: (context, index) {
//                 final item = order.items[index];
//                 return ListTile(
//                   title: Text(item.itemName),
//                   subtitle: Text(
//                       'Quantity: ${item.quantity}, Price: \$${item.price}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medifinder/models/order_model.dart';

class OrderDetails extends StatelessWidget {
  final Order order;

  OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${order.customerName}\'s Order'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/add_bg.png'), // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(item.itemName),
                            subtitle: Text(
                                'Quantity: ${item.quantity}, Price: \$${item.price}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

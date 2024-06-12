import 'package:flutter/material.dart';
import 'package:medifinder/models/order_model.dart';
import 'package:medifinder/pages/full_screen_image.dart';

class OrderDetails extends StatelessWidget {
  final Order order;

  OrderDetails({required this.order});

  void _viewFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _acceptOrder() async {
    //final url = replace the url with actual backend endpoint;
    //Add http package to make the http request
    // final response = await //http.post(Uri.parse(url),
    // body:{'orderId': order.id},);
    // if (response.statusCode == 200){
    print('Order Accepted');
    // }
    // else{
    print('Order Accept is Failed. Please Try Again');
    //}
  }

  void _cancelOrder(BuildContext context) {
    print('Order Cancelled');
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order'),
          content: TextField(
            controller: reasonController,
            decoration:
                InputDecoration(hintText: 'Enter reason for cancellation'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                final reason = reasonController.text;
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop(); // Close the dialog
                  print('Order Cancelled with reason: $reason');
                  // This is where you would call the backend to cancel the order
                } else {
                  // Show a message if the reason is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reason cannot be empty')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
                    'assets/background.png'), // Add your background image here
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
                      itemCount: order.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == order.items.length) {
                          return Card(
                            color: Color.fromRGBO(8, 253, 228, 1),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text('View Prescription'),
                              trailing: Icon(Icons.picture_as_pdf),
                              onTap: () => _viewFullScreenImage(
                                  context, order.prescriptionUrl),
                            ),
                          );
                        } else {
                          final item = order.items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(item.itemName),
                              subtitle: Text(
                                  'Quantity: ${item.quantity}, Price: \$${item.price}'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _acceptOrder,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 69, 255, 236)),
                        child: Text(
                          'Accept Order',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _cancelOrder(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(245, 72, 70, 70)),
                        child: Text(
                          'Cancel Order',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

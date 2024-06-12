// import 'package:flutter/material.dart';

// class Drugs extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Drugs In Store'),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage('assets/images/pharmacy_bg.png'),
//                   fit: BoxFit.cover),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 10),
//               Center(
//                 child: Text(
//                   'Pharmacy Name',
//                   style: TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search drugs...',
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: 10, // Replace with number of items
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: Container(
//                         height: 130, // Adjust the height of each box
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Stack(
//                           children: [
//                             Positioned(
//                               left: 10,
//                               top: 10,
//                               child: Container(
//                                 width: 100,
//                                 height: 110,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15),
//                                   image: DecorationImage(
//                                     image: AssetImage(
//                                         'assets/images/product_img.jpg'), // Replace with relevant image
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(20),
//                               child: Center(
//                                 child: Text(
//                                   'Item ${index + 1}', // Replace with item data
//                                   style: TextStyle(fontSize: 18),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 10,
//                               right: 10,
//                               child: PopupMenuButton<String>(
//                                 itemBuilder: (context) {
//                                   return {'Edit', 'Delete'}
//                                       .map((String choice) {
//                                     return PopupMenuItem<String>(
//                                       value: choice,
//                                       child: Text(choice),
//                                     );
//                                   }).toList();
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class Drugs extends StatelessWidget {
  // Mock data for demonstration
  final List<Map<String, String>> drugs = [
    {
      'name': 'Medicine1',
      'brand': 'Brand A',
      'dosage': '500mg',
      'quantity': 'x20',
      'price': 'Rs 5.00'
    },
    {
      'name': 'Medicine2',
      'brand': 'Brand B',
      'dosage': '200mg',
      'quantity': 'x15',
      'price': 'Rs 8.00'
    },
    {
      'name': 'Medicine3',
      'brand': 'Brand C',
      'dosage': '200mg',
      'quantity': 'x15',
      'price': 'Rs 8.00'
    },
    {
      'name': 'Medicine4',
      'brand': 'Brand D',
      'dosage': '200mg',
      'quantity': 'x15',
      'price': 'Rs 8.00'
    },
    {
      'name': 'Medicine5',
      'brand': 'Brand E',
      'dosage': '200mg',
      'quantity': 'x15',
      'price': 'Rs 8.00'
    },
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drugs In Store'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Pharmacy Name',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search drugs...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: drugs.length, // Replace with number of items
                  itemBuilder: (context, index) {
                    var drug = drugs[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        height: 130, // Adjust the height of each box
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 10,
                              top: 10,
                              child: Container(
                                width: 100,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/product_img.jpg'), // Replace with relevant image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 120, top: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    drug['name'] ??
                                        '', // Display only the value
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    drug['brand'] ??
                                        '', // Display only the value
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    drug['dosage'] ??
                                        '', // Display only the value
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    drug['quantity'] ??
                                        '', // Display only the value
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    drug['price'] ??
                                        '', // Display only the value
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: PopupMenuButton<String>(
                                itemBuilder: (context) {
                                  return {'Edit', 'Delete'}
                                      .map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

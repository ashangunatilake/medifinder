// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:medifinder/services/pharmacy_database_services.dart';
// import 'package:medifinder/models/drugs_model.dart';
// import 'package:medifinder/pages/pharmacy/add_item.dart';

// class Drugs extends StatefulWidget {
//   @override
//   _DrugsState createState() => _DrugsState();
// }

// class _DrugsState extends State<Drugs> {
//   final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
//   late DocumentSnapshot pharmacyDoc;
//   Map<String, dynamic>? pharmacyData;
//   List<DrugsModel> drugs = [];
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchPharmacyData();
//   }

//   Future<void> _fetchPharmacyData() async {
//     try {
//       pharmacyDoc = await _pharmacyDatabaseServices.getCurrentPharmacyDoc();
//       setState(() {
//         pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
//       });
//       _loadDrugs(); // Load drugs after pharmacy data is fetched
//     } catch (e) {
//       // Handle error
//       print('Error fetching pharmacy data: $e');
//     }
//   }

//   void _loadDrugs() {
//     _pharmacyDatabaseServices.getDrugs(pharmacyDoc.id).listen((drugList) {
//       setState(() {
//         drugs = drugList as List<DrugsModel>; //.map((doc) => DrugsModel.fromSnapshot(doc)).toList();
//       });
//     });
//   }

//   void _searchDrugs(String query) async {
//     // Uncomment and implement search logic here
//     // final results = await _pharmacyDatabaseServices.searchDrugs(query);
//     setState(() {
//       // drugs = results;
//     });
//   }

//   void deleteDrug(String drugID) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this drug?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 try {
//                   await _pharmacyDatabaseServices.deleteDrug(pharmacyDoc.id, drugID);
//                   setState(() {
//                     /////drugs.removeWhere((drug) => drug.id == drugID);
//                   });
//                   Navigator.of(context).pop(); // Close the dialog
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Drug deleted successfully')),
//                   );
//                 } catch (e) {
//                   print('Failed to delete drug: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to delete drug')),
//                   );
//                 }
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void editDrug(DrugsModel drug) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddItem(drug: drug),
//       ),
//     );
//   }

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
//                 image: AssetImage('assets/background.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 10),
//               Center(
//                 child: pharmacyData != null ? Text(
//                   pharmacyData!['Name'],
//                   style: TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ) : CircularProgressIndicator(),
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
//                   onChanged: (value) {
//                     setState(() {
//                       searchQuery = value;
//                     });
//                     _searchDrugs(value);
//                   },
//                 ),
//               ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: drugs.length,
//                   itemBuilder: (context, index) {
//                     var drug = drugs[index];
//                     return Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: Container(
//                         height: 130,
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
//                                     image: AssetImage('assets/images/product_img.jpg'),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.only(left: 120, top: 10, right: 10),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     drug.name,
//                                     style: TextStyle(fontSize: 18),
//                                   ),
//                                   Text(
//                                     drug.brand,
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                   Text(
//                                     drug.dosage,
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Positioned(
//                               right: 10,
//                               top: 10,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     'x${drug.quantity}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                   Text(
//                                     'Rs. ${drug.price}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 10,
//                               right: 10,
//                               child: PopupMenuButton<String>(
//                                 itemBuilder: (context) {
//                                   return {'Edit', 'Delete'}.map((String choice) {
//                                     return PopupMenuItem<String>(
//                                       value: choice,
//                                       child: Text(choice),
//                                     );
//                                   }).toList();
//                                 },
//                                 onSelected: (value) {
//                                   if (value == 'Edit') {
//                                     editDrug(drug); // Navigate to edit screen
//                                   } else if (value == 'Delete') {
//                                     //deleteDrug(drug.id); // Delete drug
//                                   }
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
  final List<Map<String, String>> drugs = [
    // **********Call backend to get the drug data from the form filled in add drug
    // Below is shown a Mock data for demonstration
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
                  // Add onChanged callback to handle search functionality
                  onChanged: (value) {
                    // ***************Call backend search function here
                  },
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
                                onSelected: (value) {
                                  if (value == 'Edit') {
                                    // *********Call backend edit function here
                                  } else if (value == 'Delete') {
                                    // ***********Call backend delete function here
                                  }
                                },
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

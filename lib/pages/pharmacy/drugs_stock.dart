// import 'package:flutter/material.dart';
// import 'package:medifinder/services/pharmacy_database_services.dart';
// import 'package:medifinder/models/drugs_model.dart';
// import 'package:medifinder/pages/pharmacy/add_item.dart';
//
// class Drugs extends StatefulWidget {
//   @override
//   _DrugsState createState() => _DrugsState();
// }
//
// class _DrugsState extends State<Drugs> {
//   final PharmacyDatabaseServices dbService = PharmacyDatabaseServices();
//   List<DrugsModel> drugs = [];
//   String searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDrugs();
//   }
//
//   void _loadDrugs() {
//     dbService.getDrugs().listen((drugList) {
//       setState(() {
//         drugs = drugList;
//       });
//     });
//   }
//
//   void _searchDrugs(String query) async {
//     final results = await dbService.searchDrugs(query);
//     setState(() {
//       drugs = results;
//     });
//   }
//
//   void deleteDrug(String drugId) {
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
//                   await dbService.deleteDrug(drugId);
//                   setState(() {
//                     drugs.removeWhere((drug) => drug.id == drugId);
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
//
//   void editDrug(DrugsModel drug) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddItem(drug: drug),
//       ),
//     );
//   }
//
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
//                 child: Text(
//                   'Pharmacy Name',
//                   style: TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.bold,
//                   ),
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
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
//                                     image: AssetImage(
//                                         'assets/images/product_img.jpg'),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.only(
//                                   left: 120, top: 10, right: 10),
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
//                                   return {'Edit', 'Delete'}
//                                       .map((String choice) {
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
//                                     deleteDrug(drug.id); // Delete drug
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

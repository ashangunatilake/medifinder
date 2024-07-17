// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:medifinder/services/exception_handling_services.dart';
// import 'package:medifinder/services/pharmacy_database_services.dart';
// import 'package:medifinder/models/drugs_model.dart';
// import 'package:medifinder/snackbars/snackbar.dart';

// class Drugs extends StatelessWidget {
//   final PharmacyDatabaseServices _pharmacyDatabaseServices =
//       PharmacyDatabaseServices();
//   final TextEditingController searchController = TextEditingController();
//   List<String> drugNames = [];
//   late DocumentSnapshot searchedDrugDoc;
//   late List<DocumentSnapshot> searchedDrugDocsList;

//   Future<void> pharmacyDeleteDrug(BuildContext context, String drugID) async {
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
//                   final String uid =
//                       await _pharmacyDatabaseServices.getCurrentPharmacyUid();
//                   await _pharmacyDatabaseServices.deleteDrug(uid, drugID);
//                   print('Drug deleted successfully!');
//                   Navigator.of(context)
//                       .pop(); // Close the dialog after deletion
//                   Future.delayed(Duration.zero).then((value) =>
//                       Snackbars.successSnackBar(
//                           message: "Drug deleted successfully",
//                           context: context));
//                 } catch (e) {
//                   print("Error deleting drug: $e");
//                   Snackbars.errorSnackBar(
//                       message: "Error deleting drug", context: context);
//                 }
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> pharmacyEditDrug(
//       BuildContext context, String drugID, DrugsModel drug) async {
//     final nameController = TextEditingController(text: drug.name);
//     final brandNameController = TextEditingController(text: drug.brand);
//     final dosageController = TextEditingController(text: drug.dosage);
//     final quantityController =
//         TextEditingController(text: drug.quantity.toString());
//     final unitPriceController =
//         TextEditingController(text: drug.price.toString());

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled:
//           true, // Ensures the modal sheet takes full screen height
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             top: 20.0,
//             left: 20.0,
//             right: 20.0,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Edit Drug',
//                     style:
//                         TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(labelText: 'Name'),
//                   enabled: false,
//                 ),
//                 TextField(
//                   controller: brandNameController,
//                   decoration: InputDecoration(labelText: 'Brand'),
//                   enabled: false,
//                 ),
//                 TextField(
//                   controller: dosageController,
//                   decoration: InputDecoration(labelText: 'Dosage'),
//                   enabled: false,
//                 ),
//                 TextField(
//                   controller: quantityController,
//                   decoration: InputDecoration(labelText: 'Quantity'),
//                 ),
//                 TextField(
//                   controller: unitPriceController,
//                   decoration: InputDecoration(labelText: 'Price'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       final String uid = await _pharmacyDatabaseServices
//                           .getCurrentPharmacyUid();
//                       DrugsModel updatedDrug = drug;
//                       updatedDrug = updatedDrug.copyWith(
//                         quantity: double.parse(quantityController.text.trim()),
//                         price: double.parse(unitPriceController.text.trim()),
//                       );
//                       await _pharmacyDatabaseServices.updateDrug(
//                           uid, drugID, updatedDrug);

//                       Navigator.of(context).pop(); // Close the bottom sheet
//                       Snackbars.successSnackBar(
//                           message: "Drug updated successfully",
//                           context: context);
//                     } catch (e) {
//                       print("Error updating drug: $e");
//                       Snackbars.errorSnackBar(
//                           message: "Error updating drug", context: context);
//                     }
//                   },
//                   child: Text('Done'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _pharmacyDatabaseServices.getCurrentPharmacyUid(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         }
//         final String uid = snapshot.data!;

//         return Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: AppBar(
//             title: const Text("Drugs in Store"),
//             backgroundColor: Colors.white54,
//             elevation: 0.0,
//             titleTextStyle:
//                 const TextStyle(fontSize: 18.0, color: Colors.black),
//           ),
//           body: Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/background.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SafeArea(
//                   child: SizedBox(
//                     height: 10.0,
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     'Pharmacy Name',
//                     style: TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: TypeAheadField(
//                     controller: searchController,
//                     builder: (context, controller, focusNode) {
//                       return TextField(
//                         controller: searchController,
//                         focusNode: focusNode,
//                         decoration: InputDecoration(
//                             hintText: 'Search drugs...',
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 15,
//                             ),
//                             suffixIcon: IconButton(
//                               onPressed: () async {
//                                 try {
//                                   searchedDrugDoc =
//                                       await _pharmacyDatabaseServices
//                                           .getDrugByName(
//                                               searchController.text.trim(),
//                                               uid);
//                                   if (!searchedDrugDoc.exists) {
//                                     searchedDrugDocsList =
//                                         await _pharmacyDatabaseServices
//                                             .getDrugsByBrandName(
//                                                 searchController.text.trim(),
//                                                 uid);
//                                   }
//                                   //print(searchedDrugDoc['Name']);
//                                   //print(searchedDrugDoc['BrandName']);
//                                   //print(searchedDrugDoc['Dosage']);
//                                   //print(searchedDrugDoc['Quantity']);
//                                   //print(searchedDrugDoc['UnitPrice']);
//                                 } catch (e) {
//                                   if (e is DrugNameException) {
//                                     Snackbars.errorSnackBar(
//                                         message: e.message, context: context);
//                                   } else if (e is DrugBrandNameException) {
//                                     Snackbars.errorSnackBar(
//                                         message: e.message, context: context);
//                                   } else {
//                                     Snackbars.errorSnackBar(
//                                         message: 'Error placing order: $e',
//                                         context: context);
//                                   }
//                                 }
//                               },
//                               icon: const Icon(
//                                 Icons.search,
//                                 color: Color(0xFFC4C4C4),
//                               ),
//                             )),
//                       );
//                     },
//                     itemBuilder: (context, dynamic suggestion) {
//                       return ListTile(
//                         title: Text(suggestion!),
//                       );
//                     },
//                     onSelected: (dynamic suggestion) {
//                       FocusManager.instance.primaryFocus?.unfocus();
//                       searchController.text = suggestion!;
//                     },
//                     suggestionsCallback: (textEditingValue) {
//                       if (textEditingValue != null &&
//                           textEditingValue.length > 0) {
//                         List<String> suggestions = drugNames
//                             .where((element) => element
//                                 .toLowerCase()
//                                 .contains(textEditingValue.toLowerCase()))
//                             .toList();
//                         suggestions.sort((a, b) =>
//                             a.toLowerCase().compareTo(b.toLowerCase()));
//                         return suggestions;
//                       } else {
//                         return [];
//                       }
//                     },
//                     emptyBuilder: (context) {
//                       return SizedBox();
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Expanded(
//                   child: StreamBuilder(
//                     stream: _pharmacyDatabaseServices.getDrugs(uid),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return Center(child: Text('No drugs available'));
//                       }

//                       var drugs = snapshot.data!.docs;

//                       return ListView.builder(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         itemCount: drugs.length,
//                         itemBuilder: (context, index) {
//                           DrugsModel drug = drugs[index].data();
//                           drugNames.addAll([drug.name, drug.brand]);

//                           return Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10),
//                             child: Container(
//                               height: 130, // Adjust the height of each box
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     left: 10,
//                                     top: 10,
//                                     child: Container(
//                                       width: 100,
//                                       height: 110,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                         image: DecorationImage(
//                                           image: AssetImage(
//                                               'assets/images/product_img.jpg'), // Replace with relevant image
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(
//                                         left: 120, top: 10, right: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           drug.name,
//                                           style: TextStyle(fontSize: 18),
//                                         ),
//                                         Text(
//                                           drug.brand,
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                         Text(
//                                           drug.dosage,
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Positioned(
//                                     right: 10,
//                                     top: 10,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           drug.quantity.toString(),
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                         Text(
//                                           "Rs. ${drug.price.toString()}",
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Positioned(
//                                     bottom: 10,
//                                     right: 10,
//                                     child: PopupMenuButton<String>(
//                                       onSelected: (value) {
//                                         if (value == 'Edit') {
//                                           pharmacyEditDrug(
//                                               context, drugs[index].id, drug);
//                                         } else if (value == 'Delete') {
//                                           pharmacyDeleteDrug(
//                                               context, drugs[index].id);
//                                         }
//                                       },
//                                       itemBuilder: (context) {
//                                         return {'Edit', 'Delete'}
//                                             .map((String choice) {
//                                           return PopupMenuItem<String>(
//                                             value: choice,
//                                             child: Text(choice),
//                                           );
//                                         }).toList();
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medifinder/services/exception_handling_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/models/drugs_model.dart';
import 'package:medifinder/snackbars/snackbar.dart';

class Drugs extends StatefulWidget {
  @override
  _DrugsState createState() => _DrugsState();
}

class _DrugsState extends State<Drugs> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices =
      PharmacyDatabaseServices();
  final TextEditingController searchController = TextEditingController();
  List<String> drugNames = [];
  late DocumentSnapshot searchedDrugDoc;
  late List<DocumentSnapshot> searchedDrugDocsList;
  List<DrugsModel> _filteredDrugs = [];
  List<DrugsModel> _drugs = [];
  Duration debounceDuration = Duration(milliseconds: 300);
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    _fetchDrugs();
    _filteredDrugs = _drugs;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // Future<void> _fetchDrugs() async {
  //   final String uid = await _pharmacyDatabaseServices.getCurrentPharmacyUid();
  //   final drugsSnapshot = await _pharmacyDatabaseServices.getDrugs(uid).first;
  //   setState(() {
  //     _drugs = drugsSnapshot.docs
  //         .map((doc) => DrugsModel.fromSnapshot(
  //             doc as DocumentSnapshot<Map<String, dynamic>>))
  //         .toList();
  //     _filteredDrugs = _drugs;
  //   });
  // }

  Future<void> _fetchDrugs() async {
    try {
      // Step 1: Get the current pharmacy UID
      final String uid =
          await _pharmacyDatabaseServices.getCurrentPharmacyUid();
      print("Pharmacy UID: $uid");

      // Step 2: Fetch the drugs snapshot
      final drugsSnapshot = await _pharmacyDatabaseServices.getDrugs(uid).first;
      print("Drugs snapshot fetched: ${drugsSnapshot.docs.length} documents");

      // Step 3: Map the snapshot to a list of DrugsModel
      final List<DrugsModel> fetchedDrugs = drugsSnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      // Step 4: Update the state with the fetched drugs
      setState(() {
        _drugs = fetchedDrugs;
        _filteredDrugs = fetchedDrugs;
      });

      print("Drugs successfully fetched and state updated");
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error fetching drugs: $e");
      Snackbars.errorSnackBar(
          message: "Error fetching drugs", context: context);
    }
  }

  void _onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      _filterDrugs();
    });
  }

  void _filterDrugs() {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(debounceDuration, () {
      String query = searchController.text.toLowerCase();
      setState(() {
        _filteredDrugs = _drugs.where((drug) {
          return drug.name.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Future<void> pharmacyDeleteDrug(BuildContext context, String drugID) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this drug?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final String uid =
                      await _pharmacyDatabaseServices.getCurrentPharmacyUid();
                  await _pharmacyDatabaseServices.deleteDrug(uid, drugID);
                  print('Drug deleted successfully!');
                  Navigator.of(context)
                      .pop(); // Close the dialog after deletion
                  Future.delayed(Duration.zero).then((value) =>
                      Snackbars.successSnackBar(
                          message: "Drug deleted successfully",
                          context: context));
                } catch (e) {
                  print("Error deleting drug: $e");
                  Snackbars.errorSnackBar(
                      message: "Error deleting drug", context: context);
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> pharmacyEditDrug(
      BuildContext context, String drugID, DrugsModel drug) async {
    final nameController = TextEditingController(text: drug.name);
    final brandNameController = TextEditingController(text: drug.brand);
    final dosageController = TextEditingController(text: drug.dosage);
    final quantityController =
        TextEditingController(text: drug.quantity.toString());
    final unitPriceController =
        TextEditingController(text: drug.price.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Ensures the modal sheet takes full screen height
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Drug',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  enabled: false,
                ),
                TextField(
                  controller: brandNameController,
                  decoration: InputDecoration(labelText: 'Brand'),
                  enabled: false,
                ),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                  enabled: false,
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: unitPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final String uid = await _pharmacyDatabaseServices
                          .getCurrentPharmacyUid();
                      DrugsModel updatedDrug = drug;
                      updatedDrug = updatedDrug.copyWith(
                        quantity: double.parse(quantityController.text.trim()),
                        price: double.parse(unitPriceController.text.trim()),
                      );
                      await _pharmacyDatabaseServices.updateDrug(
                          uid, drugID, updatedDrug);

                      Navigator.of(context).pop(); // Close the bottom sheet
                      Snackbars.successSnackBar(
                          message: "Drug updated successfully",
                          context: context);
                    } catch (e) {
                      print("Error updating drug: $e");
                      Snackbars.errorSnackBar(
                          message: "Error updating drug", context: context);
                    }
                  },
                  child: Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _pharmacyDatabaseServices.getCurrentPharmacyUid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final String uid = snapshot.data!;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("Drugs in Store"),
            backgroundColor: Colors.white54,
            elevation: 0.0,
            titleTextStyle:
                const TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SafeArea(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),
                Center(
                  child: Text(
                    'Pharmacy Name',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TypeAheadField(
                    controller: searchController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: searchController,
                        focusNode: focusNode,
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
                            suffixIcon: IconButton(
                              onPressed: () async {
                                try {
                                  searchedDrugDoc =
                                      await _pharmacyDatabaseServices
                                          .getDrugByName(
                                              searchController.text.trim(),
                                              uid);
                                  if (!searchedDrugDoc.exists) {
                                    searchedDrugDocsList =
                                        await _pharmacyDatabaseServices
                                            .getDrugsByBrandName(
                                                searchController.text.trim(),
                                                uid);
                                  }
                                  //print(searchedDrugDoc['Name']);
                                  //print(searchedDrugDoc['BrandName']);
                                  //print(searchedDrugDoc['Dosage']);
                                  //print(searchedDrugDoc['Quantity']);
                                  //print(searchedDrugDoc['UnitPrice']);
                                } catch (e) {
                                  if (e is DrugNameException) {
                                    Snackbars.errorSnackBar(
                                        message: e.message, context: context);
                                  } else if (e is DrugBrandNameException) {
                                    Snackbars.errorSnackBar(
                                        message: e.message, context: context);
                                  } else {
                                    Snackbars.errorSnackBar(
                                        message: 'Error placing order: $e',
                                        context: context);
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Color(0xFFC4C4C4),
                              ),
                            )),
                      );
                    },
                    itemBuilder: (context, dynamic suggestion) {
                      return ListTile(
                        title: Text(suggestion!),
                      );
                    },
                    onSelected: (dynamic suggestion) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      searchController.text = suggestion!;
                    },
                    suggestionsCallback: (textEditingValue) {
                      if (textEditingValue != null &&
                          textEditingValue.length > 0) {
                        List<String> suggestions = drugNames
                            .where((element) => element
                                .toLowerCase()
                                .contains(textEditingValue.toLowerCase()))
                            .toList();
                        suggestions.sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase()));
                        return suggestions;
                      } else {
                        return [];
                      }
                    },
                    emptyBuilder: (context) {
                      return SizedBox();
                    },
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder(
                    stream: _pharmacyDatabaseServices.getDrugs(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No drugs available'));
                      }

                      var drugs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: _filteredDrugs.length,
                        itemBuilder: (context, index) {
                          final drug = _filteredDrugs[index];
                          drugNames.addAll([drug.name, drug.brand]);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          drug.name,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          drug.brand,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          drug.dosage,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          drug.quantity.toString(),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          "Rs. ${drug.price.toString()}",
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
                                          pharmacyEditDrug(
                                              context, drugs[index].id, drug);
                                        } else if (value == 'Delete') {
                                          pharmacyDeleteDrug(
                                              context, drugs[index].id);
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/models/drugs_model.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class DrugStock extends StatefulWidget {
  final DocumentSnapshot pharmacyDoc;

  const DrugStock({Key? key, required this.pharmacyDoc}) : super(key: key);

  @override
  _DrugStockState createState() => _DrugStockState();
}

class _DrugStockState extends State<DrugStock> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices =
  PharmacyDatabaseServices();
  final TextEditingController searchController = TextEditingController();
  List<String> drugNames = [];
  late DocumentSnapshot searchedDrugDoc;
  late List<DocumentSnapshot> searchedDrugDocsList;
  bool searched = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    final nameController = TextEditingController(text: drug.name.toString().capitalize);
    final brandNameController = TextEditingController(text: drug.brand.toString().capitalize);
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
                        quantity: int.parse(quantityController.text.trim()),
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
        final String uid = widget.pharmacyDoc.id;
        final DocumentSnapshot pharmacyDoc = widget.pharmacyDoc;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("Drugs in Store"),
            backgroundColor: Colors.white38,
            elevation: 0.0,
            titleTextStyle:
            const TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background2.png'),
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
                    pharmacyDoc['Name'],
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
                              onPressed: ()  {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  if (searchController.text.trim().isEmpty) {
                                    searched = false;
                                  }
                                  else {
                                    searched = true;
                                  }
                                });

                              },
                              icon: const Icon(
                                Icons.search,
                                color: Color(0xFFC4C4C4),
                              ),
                            )),
                        onSubmitted: (value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            if (searchController.text.trim().isEmpty) {
                              searched = false;
                            }
                            else {
                              searched = true;
                            }
                          });
                        },
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
                      if (textEditingValue != null && textEditingValue.length > 0) {
                        List<String> suggestions = drugNames.where((element) => element.toLowerCase().contains(textEditingValue.toLowerCase())).toList();
                        suggestions.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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
                    stream: (!searched) ? _pharmacyDatabaseServices.getDrugs(uid) : _pharmacyDatabaseServices.searchDrugs(uid, searchController.text.trim().toLowerCase()),
                    builder: (context,  snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          itemCount: 6, // Display 6 skeleton items
                          itemBuilder: (context, index) {
                            return DrugItemSkeleton();
                          },
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text('No drugs available'));
                      }
                      List<DocumentSnapshot> drugs = [];
                      List<dynamic> querySnapshot = snapshot.data!.toList();
                      querySnapshot.forEach((query) {
                        drugs.addAll(query.docs);
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: drugs.length,
                        itemBuilder: (context, index) {
                          var drug = drugs[index];
                          drugNames.addAll([drug['Name'].toString().capitalize!, drug['BrandName'].toString().capitalize!]);
                          drugNames = drugNames.toSet().toList();

                          return DrugItem(
                              name: drug['Name'].toString().split(' ').map((word) => word.capitalize).join(' '),
                              brandName: drug['BrandName'].toString().split(' ').map((word) => word.capitalize).join(' '),
                              dosage: drug['Dosage'],
                              quantity: drug['Quantity'],
                              price: drug['UnitPrice'],
                              onEdit: () {
                                pharmacyEditDrug(
                                    context, drugs[index].id,
                                    DrugsModel(
                                        brand: drug['BrandName'],
                                        name: drug['Name'],
                                        dosage: drug['Dosage'],
                                        quantity: drug['Quantity'],
                                        price: drug['UnitPrice']
                                    )
                                );
                              },
                              onDelete: () {
                                pharmacyDeleteDrug(context, drugs[index].id);
                              },
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
  }
}

class DrugItem extends StatelessWidget {
  final String name;
  final String brandName;
  final String dosage;
  final int quantity;
  final double price;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  DrugItem({
    required this.name,
    required this.brandName,
    required this.dosage,
    required this.quantity,
    required this.price,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    image: AssetImage('assets/images/product_img.png'), // Replace with relevant image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 120, top: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    brandName,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    dosage,
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
                    quantity.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Rs. $price",
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
                    onEdit();
                  } else if (value == 'Delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) {
                  return {'Edit', 'Delete'}.map((String choice) {
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
  }
}

class DrugItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: Duration(milliseconds: 800),
                child: Container(
                  width: 100,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 120, top: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      width: 100,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
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
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




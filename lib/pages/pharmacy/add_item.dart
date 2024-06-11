import 'package:flutter/material.dart';
import 'package:medifinder/models/drugs_model.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';

class AddItem extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController brandnamecontroller = TextEditingController();
  TextEditingController dosagecontroller = TextEditingController();
  TextEditingController unitpricecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();

  Future<void> addToStock() async {
    try {
      String name = namecontroller.text.trim();
      String brandName = brandnamecontroller.text.trim();
      String dosage = dosagecontroller.text.trim();
      double unitPrice = unitpricecontroller.text.trim() as double;
      double quantity = quantitycontroller.text.trim() as double;

      DrugsModel drug = DrugsModel(brand: brandName, name: name, dosage: dosage, quantity: quantity, price: unitPrice);
      String pharmacyUid = await _userDatabaseServices.getCurrentUserUid();
      await _pharmacyDatabaseServices.addDrug(pharmacyUid, name, drug);
      print('New drug added successfully');
    } catch(e) {
      throw Exception('Error adding new drug: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Drug'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/add_bg.png'),
                  fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Drug Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the drug name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: brandnamecontroller,
                    decoration: InputDecoration(
                      labelText: 'Brand Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the brand name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: dosagecontroller,
                    decoration: InputDecoration(
                      labelText: 'Dosage',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the dosage';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: unitpricecontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Unit Price',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the unit price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: quantitycontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()){
                              await addToStock();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Add to Stock',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Close the keyboard before navigating back
                            FocusScope.of(context).unfocus();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pop(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
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


// Note: There's a pixel exceeding error when try to press the cancel button while the keyboad is opened. But it runs smoothly when the cancel button is pressed after closing the cancel button. 
// It should be checked**********
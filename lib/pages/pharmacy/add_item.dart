import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import '../../models/drugs_model.dart';
import '../../snackbars/snackbar.dart';

class AddItem extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController brandnamecontroller = TextEditingController();
  TextEditingController dosagecontroller = TextEditingController();
  TextEditingController unitpricecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();

  Future<void> pharmacyAddDrug(BuildContext context) async {
    try {
      final String uid = await _pharmacyDatabaseServices.getCurrentPharmacyUid();
      final drugsCollection = FirebaseFirestore.instance.collection('Pharmacies').doc(uid).collection('Drugs');
      final querySnapshot = await drugsCollection.where('Name', isEqualTo: namecontroller.text.trim()).get();

      if (querySnapshot.docs.isNotEmpty) {
        print('A drug with the same name already exists.');
        Snackbars.errorSnackBar(message: "A drug with the same name already exists", context: context);
        return;
      }

      DrugsModel drug = DrugsModel(
          brand: brandnamecontroller.text.trim(),
          name: namecontroller.text.trim(),
          dosage: dosagecontroller.text.trim(),
          quantity: int.parse(quantitycontroller.text.trim()),
          price: double.parse(unitpricecontroller.text.trim())
      );

      await _pharmacyDatabaseServices.addDrug(uid, drug);
      print('Drug added successfully!');
      Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Drug added succcessfully", context: context));
    } catch (e) {
      print("Error adding drug: $e");
      Snackbars.errorSnackBar(message: "Error adding drug", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add New Drug"),
        backgroundColor: Colors.white54,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafeArea(child: SizedBox(height: 10.0,)),
                Text(
                  'Add New Drug Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: namecontroller,
                  labelText: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the drug name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: brandnamecontroller,
                  labelText: 'Brand Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the brand name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: dosagecontroller,
                  labelText: 'Dosage',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the dosage';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: unitpricecontroller,
                  labelText: 'Unit Price',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the unit price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: quantitycontroller,
                  labelText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Process the form data
                            //***********Add backend function to handle form submission
                            await pharmacyAddDrug(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(218, 3, 240, 212),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Add to Stock',
                          style: TextStyle(color: Colors.white),
                        ),
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
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}
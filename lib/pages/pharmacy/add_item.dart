import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medifinder/drugs/names.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:medifinder/models/drugs_model.dart';
import 'package:medifinder/snackbars/snackbar.dart';

class AddItem extends StatefulWidget {
  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
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
      final querySnapshot = await drugsCollection.where('Name', isEqualTo: namecontroller.text.trim().toLowerCase()).where('BrandName', isEqualTo: brandnamecontroller.text.trim().toLowerCase()).where('Dosage', isEqualTo: dosagecontroller.text.trim()).get();

      if (querySnapshot.docs.isNotEmpty) {
        Snackbars.errorSnackBar(message: "Drug already exists", context: context);
        return;
      }

      DrugsModel drug = DrugsModel(
          brand: brandnamecontroller.text.trim().toLowerCase(),
          name: namecontroller.text.trim().toLowerCase(),
          dosage: dosagecontroller.text.trim(),
          quantity: int.parse(quantitycontroller.text.trim()),
          price: double.parse(unitpricecontroller.text.trim())
      );

      await _pharmacyDatabaseServices.addDrug(uid, drug);
      print('Drug added successfully!');
      Future.delayed(Duration.zero, () {
        Snackbars.successSnackBar(message: "Drug added successfully", context: context);
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          namecontroller.text = "";
          brandnamecontroller.text = "";
          dosagecontroller.text = "";
          unitpricecontroller.text = "";
          quantitycontroller.text = "";
        });
      });

    } catch (e) {
      print("Error adding drug: $e");
      Snackbars.errorSnackBar(message: "Error adding drug", context: context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    namecontroller.dispose();
    brandnamecontroller.dispose();
    dosagecontroller.dispose();
    quantitycontroller.dispose();
    unitpricecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add New Drug"),
        backgroundColor: Colors.white38,
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
            image: AssetImage('assets/images/background2.png'),
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
                TypeAheadField<String>(
                  controller: namecontroller,
                  builder: (context, controller, focusNode) {
                    return _buildTextField(
                      controller: namecontroller,
                      labelText: 'Name',
                      validator: (value) => Validator.validateEmptyText("Name", value),
                      focusNode: focusNode
                    );
                  },
                  itemBuilder: (context, String? suggestion) {
                    return ListTile(
                      title: Text(suggestion!),
                    );
                  },
                  onSelected: (String? suggestion) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    namecontroller.text = suggestion!;
                  },
                  suggestionsCallback: (textEditingValue) {
                    if (textEditingValue != null && textEditingValue.length > 0) {
                      List<String> suggestions = Drugs.names.where((element) => element.toLowerCase().contains(textEditingValue.toLowerCase())).toList();
                      suggestions.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
                      return suggestions;
                    }
                    else {
                      return [];
                    }
                  },
                  emptyBuilder: (context) {
                    return SizedBox();
                  },
                ),
                SizedBox(height: 20),
                TypeAheadField(
                  controller: brandnamecontroller,
                  builder: (context, controller, focusNode) {
                    return _buildTextField(
                      controller: brandnamecontroller,
                      labelText: 'Brand Name',
                      validator: (value) => Validator.validateEmptyText("Brand Name", value),
                      focusNode: focusNode
                    );
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      title: Text(suggestion!),
                    );
                  },
                  onSelected: (dynamic suggestion) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    brandnamecontroller.text = suggestion!;
                  },
                  suggestionsCallback: (textEditingValue) {
                    if (textEditingValue != null && textEditingValue.length > 0) {
                      List<String> suggestions = Drugs.brands.where((element) => element.toLowerCase().contains(textEditingValue.toLowerCase())).toList();
                      suggestions.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
                      return suggestions;
                    }
                    else {
                      return [];
                    }
                  },
                  emptyBuilder: (context) {
                    return SizedBox();
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: dosagecontroller,
                  labelText: 'Dosage',
                  validator: (value) => Validator.validateEmptyText("Dosage", value),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: unitpricecontroller,
                  labelText: 'Unit Price',
                  keyboardType: TextInputType.number,
                  validator: (value) => Validator.validateEmptyText("Unit Price", value),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: quantitycontroller,
                  labelText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validator: (value) => Validator.validateEmptyText("Quantity", value),
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
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
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